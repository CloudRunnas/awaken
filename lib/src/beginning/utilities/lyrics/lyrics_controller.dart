import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:lrc/lrc.dart';

import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'lyrics_loader.dart';
import 'lyrics_state.dart';

class LyricsController extends ChangeNotifier {
  LyricsController._();

  static final LyricsController inst = LyricsController._();

  final LyricsLoader _loader = LyricsLoader();

  CurrentLyrics current = CurrentLyrics.empty;
  MediaItem? _loadingFor;

  Lrc? get synced => current.synced;
  String get plainText => current.plainText;
  bool get isSynced => current.mode == LyricsMode.synced;
  bool get isPlain => current.mode == LyricsMode.plain;
  bool get isLoading => current.mode == LyricsMode.loading;

  String get displayText {
    if (isLoading) return current.statusMessage;
    if (isPlain) return plainText;
    if (current.statusMessage.isNotEmpty && !current.hasContent) {
      return current.statusMessage;
    }
    return plainText;
  }

  Future<void> loadForTrack(MediaItem item) async {
    _loadingFor = item;
    current = CurrentLyrics.loading;
    _notifyUi();

    final result = await _loader.load(item);
    if (_loadingFor != item) return;

    current = result;
    _notifyUi();
  }

  void resetLyrics() {
    _loadingFor = null;
    current = CurrentLyrics.empty;
    notifyListeners();
  }

  void _notifyUi() {
    notifyListeners();
    try {
      globalBigNow.rawNotify();
    } catch (_) {}
  }
}
