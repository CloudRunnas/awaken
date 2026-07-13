abstract class LyricsParse {
  String lyric;

  LyricsParse(this.lyric);

  List<LyricsLineModel> parseLines({bool isMain = true});

  bool isOK() => true;
}

class LyricsLineModel {
  String? mainText;
  String? extText;
  int? startTime;
  int? endTime;
  List<LyricSpanInfo>? spanList;

  Duration? get timeStamp =>
      startTime == null ? null : Duration(milliseconds: startTime!);
}

class LyricSpanInfo {
  int index = 0;
  int length = 0;
  int duration = 0;
  int start = 0;
  String raw = '';
}
