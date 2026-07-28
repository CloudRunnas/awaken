import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_controller.dart';

/// Compile-time config (CI dart-defines).
const String kLyricsAlignerUrl = String.fromEnvironment(
  'LYRICS_ALIGNER_URL',
  defaultValue: '',
);
const String kLyricsAlignerApiKey = String.fromEnvironment(
  'LYRICS_ALIGNER_API_KEY',
  defaultValue: '',
);

enum LyricsScanStatus {
  unknown,
  ready,
  running,
  notFound,
  failed,
}

class LyricsScanState {
  final LyricsScanStatus status;
  final String step;
  final String stepName;
  final String? jobId;
  final String? error;
  final String? lrcUrl;

  const LyricsScanState({
    this.status = LyricsScanStatus.unknown,
    this.step = '',
    this.stepName = '',
    this.jobId,
    this.error,
    this.lrcUrl,
  });

  String get detailLabel {
    switch (status) {
      case LyricsScanStatus.ready:
        return 'Lyriks vorhanden';
      case LyricsScanStatus.running:
        final progress = step.isNotEmpty ? ' ($step)' : '';
        final name = stepName.isNotEmpty ? stepName : 'fetchen';
        return 'Lyriks $name$progress';
      case LyricsScanStatus.notFound:
        return 'Keine Lyriks';
      case LyricsScanStatus.failed:
        return error?.isNotEmpty == true ? error! : 'Lyriks-Fehler';
      case LyricsScanStatus.unknown:
        return 'Nicht gescannt';
    }
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'step': step,
        'stepName': stepName,
        'jobId': jobId,
        'error': error,
        'lrcUrl': lrcUrl,
      };

  factory LyricsScanState.fromJson(Map<String, dynamic> json) {
    return LyricsScanState(
      status: LyricsScanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LyricsScanStatus.unknown,
      ),
      step: (json['step'] ?? '') as String,
      stepName: (json['stepName'] ?? '') as String,
      jobId: json['jobId'] as String?,
      error: json['error'] as String?,
      lrcUrl: json['lrcUrl'] as String?,
    );
  }
}

class LyricsBackendScanQueue extends ChangeNotifier {
  LyricsBackendScanQueue._();
  static final LyricsBackendScanQueue inst = LyricsBackendScanQueue._();

  /// Max concurrent in-flight jobs (POST + polling).
  static const int maxPollConcurrency = 30;

  /// Max concurrent audio PUTs.
  static const int maxUploadConcurrency = 5;

  static const String _hiveKey = 'lyricsBackendScanStates';

  final Map<String, LyricsScanState> _states = {};
  final Queue<MediaItem> _queue = Queue<MediaItem>();
  final Set<String> _queuedIds = {};
  int _activeJobs = 0;
  int _activeUploads = 0;
  final Queue<Completer<void>> _uploadWaiters = Queue<Completer<void>>();

  bool get isConfigured =>
      kLyricsAlignerUrl.trim().isNotEmpty &&
      kLyricsAlignerApiKey.trim().isNotEmpty;

  LyricsScanState stateFor(String trackPath) =>
      _states[trackPath] ?? const LyricsScanState();

  bool isMusicSync(String trackPath) =>
      stateFor(trackPath).status == LyricsScanStatus.ready;

  void loadFromHive() {
    final raw = musicBox.get(_hiveKey);
    if (raw is Map) {
      raw.forEach((key, value) {
        if (key is String && value is Map) {
          _states[key] = LyricsScanState.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }
    notifyListeners();
  }

  Future<void> clearScanCache() async {
    _states.clear();
    await musicBox.delete(_hiveKey);
    // Also clear app-internal LRC cache directory (not sidecars).
    try {
      final dir = Directory('${applicationFileDirectory.path}/lyrics');
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.lrc')) {
            await entity.delete();
          }
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _persist() async {
    final map = <String, Map<String, dynamic>>{};
    _states.forEach((k, v) => map[k] = v.toJson());
    await musicBox.put(_hiveKey, map);
  }

  /// Enqueue every library track after scan (App open / pull-to-refresh).
  void enqueueLibrary(List<MediaItem> items) {
    if (!isConfigured) return;
    for (final item in items) {
      enqueueIfNeeded(item, hasSyncedLyrics: _hasLocalSyncedSidecarOrCache(item.id));
    }
  }

  bool _hasLocalSyncedSidecarOrCache(String path) {
    if (path.isEmpty) return false;
    final sidecar = File(
      '${path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : '.'}/${_base(path)}.lrc',
    );
    if (sidecar.existsSync()) return true;
    try {
      final cache = File(
        '${applicationFileDirectory.path}/lyrics/${path.hashCode.abs()}.lrc',
      );
      if (cache.existsSync()) return true;
    } catch (_) {}
    return false;
  }

  void enqueueIfNeeded(MediaItem item, {required bool hasSyncedLyrics}) {
    if (!isConfigured) return;
    final path = item.id;
    if (path.isEmpty) return;

    // Local synced lyrics: skip job, but do NOT mark as MusicSync-ready.
    if (hasSyncedLyrics) return;

    final existing = _states[path];
    if (existing != null &&
        (existing.status == LyricsScanStatus.ready ||
            existing.status == LyricsScanStatus.notFound ||
            existing.status == LyricsScanStatus.running)) {
      return;
    }

    if (_queuedIds.contains(path)) return;
    _queuedIds.add(path);
    _queue.add(item);
    _pump();
  }

  void _pump() {
    while (_activeJobs < maxPollConcurrency && _queue.isNotEmpty) {
      final item = _queue.removeFirst();
      _queuedIds.remove(item.id);
      _activeJobs++;
      unawaited(_runJob(item).whenComplete(() {
        _activeJobs--;
        _pump();
      }));
    }
  }

  Future<void> _acquireUploadSlot() async {
    if (_activeUploads < maxUploadConcurrency) {
      _activeUploads++;
      return;
    }
    final waiter = Completer<void>();
    _uploadWaiters.add(waiter);
    await waiter.future;
  }

  void _releaseUploadSlot() {
    if (_uploadWaiters.isNotEmpty) {
      _uploadWaiters.removeFirst().complete();
    } else {
      _activeUploads--;
    }
  }

  Future<void> _runJob(MediaItem item) async {
    final path = item.id;
    _set(
      path,
      const LyricsScanState(
        status: LyricsScanStatus.running,
        step: '1/5',
        stepName: 'queued',
      ),
    );

    try {
      final start = await _postJob(item);
      final mode = start['mode'] as String? ?? '';
      if (mode == 'ready') {
        await _persistLrcFromUrl(path, start['lrc']?['url'] as String?);
        _set(
          path,
          LyricsScanState(
            status: LyricsScanStatus.ready,
            step: start['step'] as String? ?? '5/5',
            stepName: start['step_name'] as String? ?? 'cached',
            jobId: start['job_id'] as String?,
            lrcUrl: start['lrc']?['url'] as String?,
          ),
        );
        await LyricsController.inst.refreshIfCurrent(path);
        return;
      }
      if (mode == 'failed') {
        final status = start['status'] as String? ?? '';
        _set(
          path,
          LyricsScanState(
            status: status == 'FAILED_NO_LYRICS'
                ? LyricsScanStatus.notFound
                : LyricsScanStatus.failed,
            step: start['step'] as String? ?? '',
            stepName: start['step_name'] as String? ?? '',
            jobId: start['job_id'] as String?,
            error: start['error'] as String?,
          ),
        );
        return;
      }

      final jobId = start['job_id'] as String?;
      if (jobId == null) {
        _set(
          path,
          const LyricsScanState(
            status: LyricsScanStatus.failed,
            error: 'missing job_id',
          ),
        );
        return;
      }

      var uploaded = false;

      // Legacy: upload URL may still appear on started (old backend).
      if (mode == 'started') {
        final uploadUrl = start['upload']?['audio']?['url'] as String?;
        if (uploadUrl != null) {
          await _uploadAudioGuarded(path, uploadUrl);
          uploaded = true;
        }
      }

      // Poll until ready/failed; upload when upload_ready.
      for (var i = 0; i < 240; i++) {
        await Future.delayed(const Duration(seconds: 5));
        final status = await _getJob(jobId);
        final m = status['mode'] as String? ?? 'running';
        final step = status['step'] as String? ?? '';
        final stepName = status['step_name'] as String? ?? '';

        if (m == 'upload_ready' && !uploaded) {
          final uploadUrl = status['upload']?['audio']?['url'] as String?;
          if (uploadUrl == null) {
            _set(
              path,
              const LyricsScanState(
                status: LyricsScanStatus.failed,
                error: 'missing upload url',
              ),
            );
            return;
          }
          await _uploadAudioGuarded(path, uploadUrl);
          uploaded = true;
          _set(
            path,
            LyricsScanState(
              status: LyricsScanStatus.running,
              step: step,
              stepName: stepName,
              jobId: jobId,
            ),
          );
          continue;
        }

        if (m == 'ready') {
          await _persistLrcFromUrl(path, status['lrc']?['url'] as String?);
          _set(
            path,
            LyricsScanState(
              status: LyricsScanStatus.ready,
              step: step,
              stepName: stepName,
              jobId: jobId,
              lrcUrl: status['lrc']?['url'] as String?,
            ),
          );
          await LyricsController.inst.refreshIfCurrent(path);
          return;
        }
        if (m == 'failed') {
          final st = status['status'] as String? ?? '';
          _set(
            path,
            LyricsScanState(
              status: st == 'FAILED_NO_LYRICS'
                  ? LyricsScanStatus.notFound
                  : LyricsScanStatus.failed,
              step: step,
              stepName: stepName,
              jobId: jobId,
              error: status['error'] as String?,
            ),
          );
          return;
        }
        _set(
          path,
          LyricsScanState(
            status: LyricsScanStatus.running,
            step: step,
            stepName: stepName,
            jobId: jobId,
          ),
        );
      }
      _set(
        path,
        const LyricsScanState(
          status: LyricsScanStatus.failed,
          error: 'timeout',
        ),
      );
    } catch (e) {
      _set(
        path,
        LyricsScanState(
          status: LyricsScanStatus.failed,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _uploadAudioGuarded(String path, String uploadUrl) async {
    await _acquireUploadSlot();
    try {
      await _uploadAudio(path, uploadUrl);
    } finally {
      _releaseUploadSlot();
    }
  }

  void _set(String path, LyricsScanState state) {
    _states[path] = state;
    _persist();
    notifyListeners();
  }

  Uri _jobsUri([String? jobId]) {
    final base = kLyricsAlignerUrl.endsWith('/')
        ? kLyricsAlignerUrl.substring(0, kLyricsAlignerUrl.length - 1)
        : kLyricsAlignerUrl;
    if (jobId == null) return Uri.parse('$base/jobs');
    return Uri.parse('$base/jobs/$jobId');
  }

  Future<Map<String, dynamic>> _postJob(MediaItem item) async {
    final filename = item.id.split('/').last;
    final body = {
      'artist': item.artist ?? '',
      'title': item.title,
      'album': item.album ?? '',
      'duration_ms': item.duration?.inMilliseconds ?? 0,
      'audio_filename': filename,
      'voice': 'de',
    };
    final res = await http.post(
      _jobsUri(),
      headers: {
        'content-type': 'application/json',
        'x-api-key': kLyricsAlignerApiKey,
      },
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('invalid job response');
    }
    if (res.statusCode >= 400) {
      throw StateError(decoded['error']?.toString() ?? 'HTTP ${res.statusCode}');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> _getJob(String jobId) async {
    final res = await http.get(
      _jobsUri(jobId),
      headers: {'x-api-key': kLyricsAlignerApiKey},
    );
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('invalid status response');
    }
    return decoded;
  }

  Future<void> _uploadAudio(String path, String uploadUrl) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final res = await http.put(
      Uri.parse(uploadUrl),
      headers: {'content-type': 'application/octet-stream'},
      body: bytes,
    );
    if (res.statusCode >= 400) {
      throw StateError('upload failed HTTP ${res.statusCode}');
    }
  }

  Future<void> _persistLrcFromUrl(String trackPath, String? url) async {
    if (url == null || url.isEmpty) return;
    final res = await http.get(Uri.parse(url));
    if (res.statusCode >= 400) {
      throw StateError('lrc download failed HTTP ${res.statusCode}');
    }
    final content = utf8.decode(res.bodyBytes);
    // Sidecar next to audio
    try {
      final dir = trackPath.contains('/')
          ? trackPath.substring(0, trackPath.lastIndexOf('/'))
          : '.';
      final sidecar = File('$dir/${_base(trackPath)}.lrc');
      await sidecar.writeAsString(content);
    } catch (_) {
      // Fall through to app cache
    }
    // App cache fallback / mirror
    try {
      final cache = File(
        '${applicationFileDirectory.path}/lyrics/${trackPath.hashCode.abs()}.lrc',
      );
      await cache.parent.create(recursive: true);
      await cache.writeAsString(content);
    } catch (_) {}
  }

  static String _base(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}
