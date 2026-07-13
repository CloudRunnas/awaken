import 'models.dart';

class LRCParserQrc extends LyricsParse {
  RegExp advancedPattern = RegExp(r"""\[\d+,\d+]""");
  RegExp qrcPattern = RegExp(r"""\((\d+,\d+)\)""");
  RegExp advancedValuePattern = RegExp(r"\[(\d*,\d*)\]");

  LRCParserQrc(super.lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    lyric = RegExp(r"""LyricContent="([\s\S]*)">""")
            .firstMatch(lyric)
            ?.group(1) ??
        lyric;
    final lines = lyric.split('\n');
    if (lines.isEmpty) return [];

    final lineList = <LyricsLineModel>[];
    for (final line in lines) {
      final time = advancedPattern.stringMatch(line);
      if (time == null) continue;

      final ts = int.parse(
        advancedValuePattern.firstMatch(time)?.group(1)?.split(',')[0] ?? '0',
      );
      final realLyrics = line.replaceFirst(advancedPattern, '');
      final spanList = getSpanList(realLyrics);

      lineList.add(
        LyricsLineModel()
          ..mainText = realLyrics.replaceAll(qrcPattern, '')
          ..startTime = ts
          ..spanList = spanList,
      );
    }
    return lineList;
  }

  List<LyricSpanInfo> getSpanList(String realLyrics) {
    var invalidLength = 0;
    var startIndex = 0;
    return qrcPattern.allMatches(realLyrics).map((element) {
      final span = LyricSpanInfo();
      span.raw = realLyrics.substring(startIndex + invalidLength, element.start);

      final elementText = element.group(0) ?? '';
      span.index = startIndex;
      span.length = element.start - span.index - invalidLength;
      invalidLength += elementText.length;
      startIndex += span.length;

      final time = element.group(1)?.split(',') ?? ['0', '0'];
      span.start = int.parse(time[0]);
      span.duration = int.parse(time[1]);
      return span;
    }).toList();
  }

  @override
  bool isOK() {
    return lyric.contains('LyricContent=') ||
        advancedPattern.stringMatch(lyric) != null;
  }
}
