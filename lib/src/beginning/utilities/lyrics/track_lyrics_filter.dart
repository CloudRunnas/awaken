import 'dart:io';

import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_backend_scan.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_extensions.dart';

/// Fast local classification for Tracks-tab filters (no embedded tag I/O).
enum TrackLyricsFilterKind {
  none,
  plain,
  synced,
  musicSync,
}

enum TracksLyricsFilter {
  all,
  noLyrics,
  withLyrics,
  withSyncedLyrics,
  withMusicSyncLyrics,
}

class TrackLyricsClassifier {
  TrackLyricsClassifier._();

  static String _base(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  static bool hasSyncedFile(String path) {
    if (path.isEmpty) return false;
    final dir = path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : '.';
    for (final name in [
      '$_base(path).lrc',
      '$_base(path).LRC',
      '${_base(path).toLowerCase()}.lrc',
    ]) {
      if (File('$dir/$name').existsSync()) return true;
    }
    try {
      final cache = File(
        '${applicationFileDirectory.path}/lyrics/${path.hashCode.abs()}.lrc',
      );
      if (cache.existsSync()) return true;
    } catch (_) {}
    return false;
  }

  static bool hasPlainHive(String path) {
    try {
      final raw = musicBox.get('offlineLyrics');
      if (raw is! Map) return false;
      final value = raw[path];
      if (value is! String || value.trim().isEmpty) return false;
      // Valid LRC in hive counts as synced, not plain.
      if (value.isValidLRC()) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool hasHiveSynced(String path) {
    try {
      final raw = musicBox.get('offlineLyrics');
      if (raw is! Map) return false;
      final value = raw[path];
      if (value is! String || value.trim().isEmpty) return false;
      return value.isValidLRC();
    } catch (_) {
      return false;
    }
  }

  static TrackLyricsFilterKind classify(String path) {
    if (LyricsBackendScanQueue.inst.isMusicSync(path)) {
      return TrackLyricsFilterKind.musicSync;
    }
    if (hasSyncedFile(path) || hasHiveSynced(path)) {
      return TrackLyricsFilterKind.synced;
    }
    if (hasPlainHive(path)) {
      return TrackLyricsFilterKind.plain;
    }
    return TrackLyricsFilterKind.none;
  }

  static bool matches(String path, TracksLyricsFilter filter) {
    final kind = classify(path);
    switch (filter) {
      case TracksLyricsFilter.all:
        return true;
      case TracksLyricsFilter.noLyrics:
        return kind == TrackLyricsFilterKind.none;
      case TracksLyricsFilter.withLyrics:
        return kind == TrackLyricsFilterKind.plain;
      case TracksLyricsFilter.withSyncedLyrics:
        return kind == TrackLyricsFilterKind.synced ||
            kind == TrackLyricsFilterKind.musicSync;
      case TracksLyricsFilter.withMusicSyncLyrics:
        return kind == TrackLyricsFilterKind.musicSync;
    }
  }
}
