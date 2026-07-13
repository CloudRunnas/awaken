import 'lyrics_state.dart';

abstract class LyricsRemoteProvider {
  Future<RemoteLyricsResult?> fetch(LyricsSearchQuery query);
}

class NoOpLyricsRemoteProvider implements LyricsRemoteProvider {
  const NoOpLyricsRemoteProvider();

  @override
  Future<RemoteLyricsResult?> fetch(LyricsSearchQuery query) async => null;
}
