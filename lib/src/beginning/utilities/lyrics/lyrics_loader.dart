import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:on_audio_edit/on_audio_edit.dart';
import 'package:lrc/lrc.dart';

import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'lyrics_extensions.dart';
import 'lyrics_remote_provider.dart';
import 'lyrics_state.dart';

String _basenameWithoutExtension(String path) {
  final name = path.split('/').last;
  final dot = name.lastIndexOf('.');
  return dot > 0 ? name.substring(0, dot) : name;
}

String _dirname(String path) {
  final index = path.lastIndexOf('/');
  return index >= 0 ? path.substring(0, index) : '.';
}

class LyricsLoader {
  LyricsLoader({LyricsRemoteProvider? remoteProvider})
      : _remoteProvider = remoteProvider ?? const NoOpLyricsRemoteProvider();

  final LyricsRemoteProvider _remoteProvider;

  bool get prioritizeEmbedded =>
      musicBox.get('prioritizeEmbeddedLyrics') ?? false;

  Future<CurrentLyrics> load(MediaItem item) async {
    final trackPath = item.id;
    if (trackPath.isEmpty) {
      return const CurrentLyrics(
        statusMessage: "Couldn't find any matching lyrics.",
      );
    }

    final embedded = await _readEmbeddedLyrics(trackPath);

    if (prioritizeEmbedded && embedded.isNotEmpty) {
      final fromEmbedded = _parseEmbedded(embedded);
      if (fromEmbedded != null) return fromEmbedded;
    }

    final sidecar = await _readSidecarLrc(trackPath);
    if (sidecar != null) {
      final lrc = sidecar.content.parseLRC();
      if (lrc != null && lrc.lyrics.isNotEmpty) {
        return CurrentLyrics(
          mode: LyricsMode.synced,
          synced: lrc,
          source: LyricsSource.sidecar,
        );
      }
    }

    final cachedLrc = await _readCachedLrc(trackPath);
    if (cachedLrc != null) {
      final lrc = cachedLrc.parseLRC();
      if (lrc != null && lrc.lyrics.isNotEmpty) {
        return CurrentLyrics(
          mode: LyricsMode.synced,
          synced: lrc,
          source: LyricsSource.cache,
        );
      }
    }

    if (!prioritizeEmbedded && embedded.isNotEmpty) {
      final fromEmbedded = _parseEmbedded(embedded);
      if (fromEmbedded != null) return fromEmbedded;
    }

    final hivePlain = _readHivePlain(trackPath);
    if (hivePlain != null && hivePlain.trim().isNotEmpty) {
      if (hivePlain.isValidLRC()) {
        final lrc = hivePlain.parseLRC();
        if (lrc != null && lrc.lyrics.isNotEmpty) {
          return CurrentLyrics(
            mode: LyricsMode.synced,
            synced: lrc,
            source: LyricsSource.hive,
          );
        }
      }
      return CurrentLyrics(
        mode: LyricsMode.plain,
        plainText: cleanPlainLyrics(hivePlain),
        source: LyricsSource.hive,
      );
    }

    final remote = await _remoteProvider.fetch(
      LyricsSearchQuery(
        trackPath: trackPath,
        title: item.title,
        artist: item.artist ?? '',
        duration: item.duration,
      ),
    );
    if (remote != null && remote.content.trim().isNotEmpty) {
      if (remote.synced) {
        final lrc = remote.content.parseLRC();
        if (lrc != null && lrc.lyrics.isNotEmpty) {
          await _writeCachedLrc(trackPath, remote.content);
          return CurrentLyrics(
            mode: LyricsMode.synced,
            synced: lrc,
            source: LyricsSource.cache,
          );
        }
      }
      return CurrentLyrics(
        mode: LyricsMode.plain,
        plainText: cleanPlainLyrics(remote.content),
        source: LyricsSource.cache,
      );
    }

    if (embedded.isNotEmpty) {
      return CurrentLyrics(
        mode: LyricsMode.plain,
        plainText: cleanPlainLyrics(embedded),
        source: LyricsSource.embedded,
      );
    }

    return const CurrentLyrics(
      statusMessage: "Couldn't find any matching lyrics.",
    );
  }

  CurrentLyrics? _parseEmbedded(String embedded) {
    final lrc = embedded.parseLRC();
    if (lrc != null && lrc.lyrics.isNotEmpty) {
      return CurrentLyrics(
        mode: LyricsMode.synced,
        synced: lrc,
        source: LyricsSource.embedded,
      );
    }
    final plain = cleanPlainLyrics(embedded);
    if (plain.trim().isNotEmpty) {
      return CurrentLyrics(
        mode: LyricsMode.plain,
        plainText: plain,
        source: LyricsSource.embedded,
      );
    }
    return null;
  }

  Future<String> _readEmbeddedLyrics(String trackPath) async {
    try {
      final tag = await OnAudioEdit()
          .readSingleAudioTag(trackPath, TagType.LYRICS);
      return tag.trim();
    } catch (_) {
      return '';
    }
  }

  Future<({String content, String path})?> _readSidecarLrc(
      String trackPath) async {
    for (final candidate in _sidecarCandidates(trackPath)) {
      if (await candidate.exists()) {
        final content = await candidate.readLrcString();
        if (content.trim().isNotEmpty) {
          return (content: content, path: candidate.path);
        }
      }
    }
    return null;
  }

  List<File> _sidecarCandidates(String trackPath) {
    final dir = _dirname(trackPath);
    final base = _basenameWithoutExtension(trackPath);
    return [
      File('$dir/$base.lrc'),
      File('$dir/$base.LRC'),
      File('$dir/${base.toLowerCase()}.lrc'),
    ];
  }

  Future<String?> _readCachedLrc(String trackPath) async {
    final file = _cachedLrcFile(trackPath);
    if (!await file.exists()) return null;
    final content = await file.readLrcString();
    return content.trim().isEmpty ? null : content;
  }

  Future<void> _writeCachedLrc(String trackPath, String content) async {
    final file = _cachedLrcFile(trackPath);
    final dir = file.parent;
    if (!await dir.exists()) await dir.create(recursive: true);
    await file.writeAsString(content);
  }

  File _cachedLrcFile(String trackPath) {
    return File(
      '${applicationFileDirectory.path}/lyrics/${trackPath.hashCode.abs()}.lrc',
    );
  }

  String? _readHivePlain(String trackPath) {
    final offline = musicBox.get('offlineLyrics');
    if (offline is Map && offline.containsKey(trackPath)) {
      final value = offline[trackPath];
      if (value is String &&
          value != "Couldn't find any matching lyrics." &&
          value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
