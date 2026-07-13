import 'models.dart';
import 'parser_lrc.dart';
import 'parser_qrc.dart';

class LRCParserSmart extends LyricsParse {
  LRCParserSmart(super.lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    final qrc = LRCParserQrc(lyric);
    if (qrc.isOK()) {
      return qrc.parseLines(isMain: isMain);
    }
    return LRCParserLrc(lyric).parseLines(isMain: isMain);
  }
}
