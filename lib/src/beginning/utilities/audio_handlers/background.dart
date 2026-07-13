import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phoenix/src/beginning/utilities/global_variables.dart';

class AudioPlayerTask extends BaseAudioHandler {
  AudioPlayerTask() {
    _init();
  }
  List<MediaItem> leQueue = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  int indexOfQueue = 0;
  int addToQueueIndex = -1;
  AudioProcessingState? _skipState;
  late StreamSubscription<PlaybackEvent> _eventSubscription;
  late ConcatenatingAudioSource source;
  int clicks = 0;
  final Map<String, Future<String>> _preprocessInFlight = {};

  _init() {
    // Broadcast that we're connecting, and what controls are available.
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      _broadcastState();
    });
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        mediaItem.add(leQueue[index]);
        indexOfQueue = index;
        if (addToQueueIndex == index) {
          addToQueueIndex = -1;
        }
      }
    });

    _audioPlayer.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          break;
        case ProcessingState.ready:
          _skipState = null;
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    if (addToQueueIndex == -1) {
      addToQueueIndex = indexOfQueue + 1;
    } else {
      addToQueueIndex += 1;
    }
    leQueue.insert(addToQueueIndex, mediaItem);
    source.insert(addToQueueIndex, AudioSource.uri(Uri.parse(mediaItem.id)));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    leQueue.insert(index, mediaItem);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    leQueue = queue;
    source = ConcatenatingAudioSource(
      children:
          leQueue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
    );
    await _setSourceWithPreprocessFallback(source, initialIndex: 0);
    mediaItem.add(leQueue[0]);
    _audioPlayer.setLoopMode(LoopMode.all);
    addToQueueIndex = -1;
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.all) {
      _audioPlayer.setShuffleModeEnabled(true);
    } else {
      _audioPlayer.setShuffleModeEnabled(false);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.one) {
      _audioPlayer.setLoopMode(LoopMode.one);
    } else {
      _audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (_) {
      // If the current source fails to start, try preprocessing the current track.
      final idx = _audioPlayer.currentIndex;
      if (idx == null || idx < 0 || idx >= leQueue.length) rethrow;
      final originalPath = leQueue[idx].id;
      final cachePath = await _maybePreprocessToCache(originalPath);
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.file(cachePath)),
        preload: false,
        initialIndex: 0,
      );
      await _audioPlayer.play();
    }
  }

  Future<void> _setSourceWithPreprocessFallback(ConcatenatingAudioSource src,
      {required int initialIndex}) async {
    try {
      await _audioPlayer.setAudioSource(src,
          preload: false, initialIndex: initialIndex);
    } catch (_) {
      // Fallback: preprocess only the initial item and set it as a single source.
      if (leQueue.isEmpty) rethrow;
      final originalPath = leQueue[initialIndex].id;
      final cachePath = await _maybePreprocessToCache(originalPath);
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.file(cachePath)),
        preload: false,
        initialIndex: 0,
      );
    }
  }

  Future<String> _maybePreprocessToCache(String originalPath) async {
    // Only preprocess local files.
    final originalFile = File(originalPath);
    if (!await originalFile.exists()) {
      return originalPath;
    }

    final stat = await originalFile.stat();
    final cacheDir = await getTemporaryDirectory();
    final outDir = Directory('${cacheDir.path}/preprocessed_audio');
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    final key = _fnv1a64(
      utf8.encode(
          '$originalPath|${stat.size}|${stat.modified.millisecondsSinceEpoch}'),
    );
    final outPath = '${outDir.path}/$key.mp3';

    final outFile = File(outPath);
    if (await outFile.exists()) {
      return outPath;
    }

    // Avoid duplicated preprocessing for the same key.
    _preprocessInFlight[outPath] ??= () async {
      final cmd =
          '-y -i "${_escapeForFfmpeg(originalPath)}" -codec:a libmp3lame -b:a 320k -joint_stereo 1 "${_escapeForFfmpeg(outPath)}"';
      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();
      if (rc == null || !rc.isValueSuccess()) {
        // If preprocessing fails, fall back to the original.
        return originalPath;
      }
      return outPath;
    }();

    try {
      return await _preprocessInFlight[outPath]!;
    } finally {
      _preprocessInFlight.remove(outPath);
    }
  }

  static String _escapeForFfmpeg(String path) {
    // FFmpegKit runs through a shell-like parser. Escaping quotes is sufficient here.
    return path.replaceAll('"', '\\"');
  }

  static String _fnv1a64(List<int> bytes) {
    // Deterministic, dependency-free hash for cache keying.
    const int fnvOffset = 0xcbf29ce484222325;
    const int fnvPrime = 0x100000001b3;
    var hash = fnvOffset;
    for (final b in bytes) {
      hash ^= b & 0xff;
      hash = (hash * fnvPrime) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    switch (button) {
      case MediaButton.next:
        skipToNext();
        break;
      case MediaButton.previous:
        skipToPrevious();
        break;
      case MediaButton.media:
        clicks += 1;
        if (clicks == 1) {
          Timer(const Duration(milliseconds: 500), () async {
            switch (clicks) {
              case 1:
                if (_audioPlayer.playing) {
                  _audioPlayer.pause();
                } else {
                  audioHandler.play();
                }
                clicks = 0;
                break;
              case 2:
                audioHandler.skipToNext();
                clicks = 0;
                break;
              case 3:
                audioHandler.skipToPrevious();
                clicks = 0;
                break;
              default:
                clicks = 0;
                break;
            }
          });
        }
        break;
    }
  }

  @override
  Future<void> pause() async {
    _audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    // Stop playing audio.
    _audioPlayer.stop();
    _eventSubscription.cancel();
    await _broadcastState();
    // Broadcast that we've stopped.
    playbackState.add(PlaybackState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.completed));
    // Shut down this background task
    await super.stop();
  }

  @override
  Future<void> skipToPrevious() async {
    _audioPlayer.seekToPrevious();
    if (!_audioPlayer.playing) _audioPlayer.play();
  }

  @override
  Future<void> skipToNext() async {
    _audioPlayer.seekToNext();
    if (!_audioPlayer.playing) _audioPlayer.play();
  }

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> rewind() async {
    if (_audioPlayer.position > const Duration(seconds: 5)) {
      _audioPlayer.seek(_audioPlayer.position - const Duration(seconds: 5));
    } else {
      _audioPlayer.seek(const Duration(seconds: 0));
    }
  }

  @override
  Future<void> fastForward() async {
    if (_audioPlayer.position <
        _audioPlayer.duration! - const Duration(seconds: 5)) {
      _audioPlayer.seek(_audioPlayer.position + const Duration(seconds: 5));
    } else {
      audioHandler.skipToNext();
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  Future<void> _broadcastState() async {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          MediaControl.skipToPrevious,
          if (_audioPlayer.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.fastForward,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [1, 2, 3],
        processingState: _getProcessingState()!,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
      ),
    );
  }

  AudioProcessingState? _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_audioPlayer.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}
