import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:lrc/lrc.dart';
import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/widgets/lyrics/lyrics_interactive_line.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class TextWithFadingProgress extends StatelessWidget {
  final List<LrcLinePart> parts;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Duration position;
  final bool playing;

  const TextWithFadingProgress({
    super.key,
    required this.parts,
    required this.textStyle,
    required this.textAlign,
    required this.textDirection,
    required this.position,
    required this.playing,
  });

  @override
  Widget build(BuildContext context) {
    final normalColor = textStyle.color ?? Colors.white;
    final dimmedColor = normalColor.withValues(alpha: 0.25);

    return Text.rich(
      TextSpan(
        children: parts.map((part) {
          final didReach = position > part.startTimestamp;
          var animationDuration =
              playing ? part.endTimestamp - part.startTimestamp : Duration.zero;
          if (animationDuration <= Duration.zero) {
            animationDuration = const Duration(milliseconds: 10);
          }

          final child = Text(
            part.lyrics,
            style: textStyle,
            textAlign: TextAlign.start,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          );

          return WidgetSpan(
            child: TweenAnimationBuilder<double>(
              duration: animationDuration,
              tween: Tween(begin: 0.0, end: didReach ? 1.0 : 0.0),
              builder: (context, progress, _) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [normalColor, normalColor, dimmedColor],
                    stops: [
                      0,
                      progress,
                      progress == 0 ? 0.0 : progress + 0.1,
                    ],
                  ).createShader(bounds, textDirection: textDirection),
                  blendMode: BlendMode.dstIn,
                  child: ClipRect(child: child),
                );
              },
            ),
          );
        }).toList(),
      ),
      textDirection: textDirection,
      textAlign: textAlign,
    );
  }
}

class LyricsLRCParsedView extends StatefulWidget {
  final Widget background;
  final bool isFullScreenView;
  final bool canShowToggleFullscreenButton;
  final VoidCallback? onFullscreenTap;
  final Lrc? lrc;
  final String plainText;
  final Color textColor;
  final Color highlightColor;
  final double fontSize;
  final bool stretchLyricsDuration;

  const LyricsLRCParsedView({
    super.key,
    required this.background,
    required this.lrc,
    this.plainText = '',
    this.isFullScreenView = false,
    this.canShowToggleFullscreenButton = false,
    this.onFullscreenTap,
    this.textColor = Colors.white,
    this.highlightColor = Colors.white24,
    this.fontSize = 16,
    this.stretchLyricsDuration = true,
  });

  @override
  State<LyricsLRCParsedView> createState() => LyricsLRCParsedViewState();
}

class LyricsLRCParsedViewState extends State<LyricsLRCParsedView> {
  late final ListController _listController;
  late final ScrollController _scrollController;

  static const _lrcJumpAnimationDuration = Duration(milliseconds: 300);
  static const int _lrcOpacityDurationMS = 500;

  late final double _paddingVertical =
      widget.isFullScreenView ? 32 * 12.0 : 12 * 12.0;

  int? _currentIndex;
  String _currentLine = '';
  Lrc? _currentLrc;
  bool _isCurrentLineEmpty = true;
  bool _canAnimateScroll = true;
  bool _playing = false;
  Duration _position = Duration.zero;

  Timer? _scrollTimer;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlaybackState>? _playbackSub;
  (Duration?, int?)? _latestUpdatedLineInfo;

  List<LrcLine> lyrics = [];
  Map<Duration, List<int>> highlightTimestampsMap = {};

  final _emptyTextRegex = RegExp(r'[^\s]');

  @override
  void initState() {
    super.initState();
    _listController = ListController();
    _scrollController = ScrollController();
    _listenToPlayer();
    fillLists(widget.lrc, widget.plainText);
  }

  @override
  void didUpdateWidget(covariant LyricsLRCParsedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lrc != widget.lrc || oldWidget.plainText != widget.plainText) {
      fillLists(widget.lrc, widget.plainText);
    }
  }

  void _listenToPlayer() {
    _positionSub = AudioService.position.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
      _updateHighlightedLine(position.inMilliseconds);
    });
    _playbackSub = audioHandler.playbackState.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state.playing);
    });
  }

  bool _checkIfTextEmpty(String text) => !_emptyTextRegex.hasMatch(text);

  void clearLists() {
    highlightTimestampsMap.clear();
    lyrics.clear();
    _isCurrentLineEmpty = true;
    _latestUpdatedLineInfo = null;
    _currentIndex = null;
  }

  void fillLists(Lrc? lrc, String plainText) {
    try {
      _scrollController.jumpTo(0);
    } catch (_) {}

    _currentLrc = lrc;
    if (lrc == null) {
      clearLists();
      _isCurrentLineEmpty = plainText.trim().isEmpty;
      setState(() {});
      return;
    }

    final firstLine = lrc.lyrics.isNotEmpty ? lrc.lyrics.first.lyrics : '';
    _isCurrentLineEmpty = _checkIfTextEmpty(firstLine);

    double multiplier = 0;
    if (widget.stretchLyricsDuration) {
      multiplier = _durationMultiplier(lrc);
    }

    highlightTimestampsMap.clear();
    lyrics.clear();

    final uiInfo = lrc.forUiDisplay(
      multiplier,
      durationDifferenceToInsertEmptyLine: const Duration(seconds: 1),
      romanize: false,
    );

    lyrics = uiInfo.uiLyricsLines;
    highlightTimestampsMap = uiInfo.highlightTimestampsMap;
    _updateHighlightedLine(_position.inMilliseconds, jump: true);
    setState(() {});
  }

  double _durationMultiplier(Lrc lrc) {
    final llength = lrc.length ?? '';
    if (llength.isEmpty) return 0;

    final parts = llength.split(RegExp(r'[:.]'));
    try {
      String? hundreds;
      if (parts.length >= 3) {
        hundreds = parts[2];
        var zerosToAdd = 6 - hundreds.length;
        while (zerosToAdd > 0) {
          hundreds = '${hundreds!}0';
          zerosToAdd--;
        }
      }

      final lyricsDuration = Duration(
        minutes: int.parse(parts[0]),
        seconds: int.parse(parts[1]),
        microseconds: hundreds == null ? 0 : int.tryParse(hundreds) ?? 0,
      );
      final itemDurationMS = nowMediaItem.duration?.inMilliseconds ?? 0;
      if (itemDurationMS <= 0) return 0;
      return (itemDurationMS * 1000) / lyricsDuration.inMicroseconds;
    } catch (_) {
      return 0;
    }
  }

  void _updateHighlightedLine(int durMS, {bool jump = false, bool force = false}) {
    if (lyrics.isEmpty) return;

    LrcLine? lrcDur;
    for (var i = lyrics.length - 1; i >= 0; i--) {
      final line = lyrics[i];
      if (line.timestamp <= Duration(milliseconds: durMS + 5) &&
          !line.isBGLyrics) {
        lrcDur = line;
        break;
      }
    }

    final newLineDuration = lrcDur?.timestamp;
    int? newIndexPre = newLineDuration == null
        ? null
        : highlightTimestampsMap[newLineDuration]?.first;
    if (newIndexPre == null) return;

    if (newIndexPre + 1 == lyrics.length) {
      if (_currentIndex == newIndexPre) return;
      newIndexPre = lyrics.length - 1;
    }
    if (newIndexPre < 0) newIndexPre = 0;
    if (!force && _currentIndex == newIndexPre) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final newIndex = newIndexPre!;
      _latestUpdatedLineInfo = (lrcDur?.timestamp, newIndex);

      if (_canAnimateScroll && _listController.isAttached) {
        _currentIndex = newIndex;
        if (jump) {
          _listController.jumpToItem(
            index: newIndex,
            scrollController: _scrollController,
            alignment: 0.4,
          );
        } else {
          _listController.animateToItem(
            index: newIndex,
            scrollController: _scrollController,
            alignment: 0.4,
            duration: (_) => _lrcJumpAnimationDuration,
            curve: (_) => Curves.easeOut,
          );
        }
        try {
          _currentLine = lyrics[newIndex].lyrics;
        } catch (_) {
          _currentLine = '';
        }
        final empty = _checkIfTextEmpty(_currentLine);
        if (empty != _isCurrentLineEmpty) {
          setState(() => _isCurrentLineEmpty = empty);
        }
      }
      setState(() {});
    });
  }

  void _onPointerDown(_) {
    _scrollTimer?.cancel();
    if (_currentLrc != null) _canAnimateScroll = false;
    if (_isCurrentLineEmpty) setState(() => _isCurrentLineEmpty = false);
  }

  void _onPointerUp(_) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_playing) {
        _canAnimateScroll = true;
        _updateHighlightedLine(_position.inMilliseconds, force: true);
      }
      if (_currentLrc != null && _checkIfTextEmpty(_currentLine)) {
        setState(() => _isCurrentLineEmpty = true);
      }
    });
  }

  Future<void> _seekToLine(LrcLine line) async {
    _canAnimateScroll = true;
    _currentIndex = null;
    await audioHandler.seek(line.timestamp);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playbackSub?.cancel();
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLrc == null) {
      return widget.background;
    }

    final fullscreen = widget.isFullScreenView;
    final selectedIndex = _latestUpdatedLineInfo?.$2;
    final selectedLineTimestamp = _latestUpdatedLineInfo?.$1;
    final normalTextStyle = TextStyle(
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w600,
      fontFamily: 'Raleway',
      color: widget.textColor,
      height: 1.4,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: _lrcOpacityDurationMS),
          opacity: _isCurrentLineEmpty ? 1.0 : 0.35,
          child: widget.background,
        ),
        Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: lyrics.isEmpty
              ? const SizedBox.shrink()
              : SuperListView.builder(
                  controller: _scrollController,
                  listController: _listController,
                  padding: EdgeInsets.symmetric(vertical: _paddingVertical),
                  itemCount: lyrics.length,
                  itemBuilder: (context, index) {
                    if (index >= lyrics.length) {
                      return const SizedBox.shrink();
                    }

                    final distanceDiff =
                        selectedIndex == null ? null : index - selectedIndex;
                    final line = lyrics[index];
                    final text = line.readableText;
                    final parts = line.parts;
                    final selected = distanceDiff == 0 ||
                        line.isBGLyrics ||
                        selectedLineTimestamp == line.timestamp;
                    final selectedAndEmpty =
                        selected && _checkIfTextEmpty(text);

                    final opacity = selected
                        ? 1.0
                        : distanceDiff?.abs() == 1
                            ? 0.5
                            : distanceDiff?.abs() == 2
                                ? 0.4
                                : 0.25;

                    final textStyle = normalTextStyle.copyWith(
                      color: widget.textColor.withValues(alpha: opacity),
                    );

                    final syncedChild = selected &&
                            parts != null &&
                            parts.isNotEmpty
                        ? TextWithFadingProgress(
                            parts: parts,
                            textStyle: textStyle,
                            textAlign: TextAlign.center,
                            textDirection: line.isRTL
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            position: _position,
                            playing: _playing,
                          )
                        : null;

                    return AnimatedScale(
                      scale: selected ? 1.0 : 0.95,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubicEmphasized,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: fullscreen ? 8 : 2,
                          horizontal: 8,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: selectedAndEmpty ? 3 : 8,
                          horizontal: selectedAndEmpty ? 24 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected && !line.isBGLyrics
                              ? widget.highlightColor
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: LyricsInteractiveLine(
                          line: line,
                          text: text,
                          textStyle: textStyle,
                          textAlign: TextAlign.center,
                          textDirection: line.isRTL
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          selected: selected,
                          syncedChild: syncedChild,
                          onSeek: () => _seekToLine(line),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (widget.canShowToggleFullscreenButton && !fullscreen)
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.open_in_full, color: widget.textColor),
              onPressed: widget.onFullscreenTap,
            ),
          ),
        if (!_canAnimateScroll && _currentLrc != null)
          Positioned(
            bottom: fullscreen ? 24 : 48,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  _canAnimateScroll = true;
                  _updateHighlightedLine(_position.inMilliseconds, force: true);
                },
                icon: Icon(Icons.my_location, color: widget.textColor),
                label: Text(
                  'Zur aktuellen Zeile',
                  style: TextStyle(color: widget.textColor),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
