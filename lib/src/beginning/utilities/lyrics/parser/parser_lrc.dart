import 'models.dart';

class LRCParserLrc extends LyricsParse {
  RegExp pattern = RegExp(r"\[\d{2}:\d{2}.\d{2,3}]");
  RegExp valuePattern = RegExp(r"\[(\d{2}:\d{2}.\d{2,3})\]");

  LRCParserLrc(super.lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    final lines = lyric.split('\n');
    if (lines.isEmpty) return [];

    final lineList = <LyricsLineModel>[];
    for (final line in lines) {
      final time = pattern.stringMatch(line);
      if (time == null) continue;

      var realLyrics = line.replaceFirst(pattern, '');
      final ts = timeTagToTS(time);
      final lineModel = LyricsLineModel()..startTime = ts;
      if (realLyrics == '//') realLyrics = '';
      if (isMain) {
        lineModel.mainText = realLyrics;
      } else {
        lineModel.extText = realLyrics;
      }
      lineList.add(lineModel);
    }
    return lineList;
  }

  int? timeTagToTS(String timeTag) {
    if (timeTag.trim().isEmpty) return null;
    final value = valuePattern.firstMatch(timeTag)?.group(1) ?? '';
    if (value.isEmpty) return null;

    final timeArray = value.split('.');
    var padZero = 3 - timeArray.last.length;
    var millisecond = timeArray.last.padRight(padZero, '0');
    if (millisecond.length > 3) {
      millisecond = millisecond.substring(0, 3);
    }
    final minAndSecArray = timeArray.first.split(':');
    return Duration(
      minutes: int.parse(minAndSecArray.first),
      seconds: int.parse(minAndSecArray.last),
      milliseconds: int.parse(millisecond),
    ).inMilliseconds;
  }
}
