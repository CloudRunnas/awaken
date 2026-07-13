import 'package:lrc/lrc.dart';

import 'parser/parser_smart.dart';

extension LRCParsingUtils on String {
  Lrc? parseLRC() {
    try {
      return toLrc();
    } catch (_) {
      try {
        final res = LRCParserSmart(this).parseLines();
        if (res.isEmpty) return null;
        final lines = <LrcLine>[];
        for (var i = 0; i < res.length; i++) {
          final e = res[i];
          lines.add(
            LrcLine(
              timestamp: e.timeStamp ?? Duration.zero,
              originalIndex: i,
              lyrics: e.mainText ?? '',
              readableText: e.mainText ?? '',
              type: LrcTypes.simple,
              parts: const [],
              person: null,
              isRTL: false,
            ),
          );
        }
        return Lrc(lyrics: lines);
      } catch (_) {}
    }
    return null;
  }

  bool isValidLRC() {
    try {
      if (LrcParser.isValid(this)) return true;
    } catch (_) {}
    try {
      return LRCParserSmart(this).parseLines().isNotEmpty;
    } catch (_) {}
    return false;
  }
}

String cleanPlainLyrics(String input) {
  return LrcParser.cleanPlainLyrics(input);
}
