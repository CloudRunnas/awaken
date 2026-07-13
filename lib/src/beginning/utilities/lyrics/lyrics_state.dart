import 'package:lrc/lrc.dart';

enum LyricsMode { none, loading, plain, synced }

enum LyricsSource { sidecar, embedded, cache, hive, none }

class CurrentLyrics {
  final LyricsMode mode;
  final Lrc? synced;
  final String plainText;
  final LyricsSource source;
  final String statusMessage;

  const CurrentLyrics({
    this.mode = LyricsMode.none,
    this.synced,
    this.plainText = '',
    this.source = LyricsSource.none,
    this.statusMessage = '',
  });

  bool get hasContent =>
      mode == LyricsMode.synced ||
      (mode == LyricsMode.plain && plainText.trim().isNotEmpty);

  static const empty = CurrentLyrics();
  static const loading = CurrentLyrics(
    mode: LyricsMode.loading,
    statusMessage: 'Searching...',
  );
}

class LyricsSearchQuery {
  final String trackPath;
  final String title;
  final String artist;
  final Duration? duration;

  const LyricsSearchQuery({
    required this.trackPath,
    required this.title,
    required this.artist,
    this.duration,
  });
}

class RemoteLyricsResult {
  final String content;
  final bool synced;

  const RemoteLyricsResult({
    required this.content,
    required this.synced,
  });
}
