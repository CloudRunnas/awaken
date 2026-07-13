import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lrc/lrc.dart';
import 'package:phoenix/src/beginning/utilities/translation/translation_service.dart';
import 'package:phoenix/src/beginning/widgets/lyrics/lyrics_translation_tooltip.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

class LyricsInteractiveLine extends StatefulWidget {
  final LrcLine line;
  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool selected;
  final Widget? syncedChild;
  final Future<void> Function() onSeek;

  const LyricsInteractiveLine({
    super.key,
    required this.line,
    required this.text,
    required this.textStyle,
    required this.textAlign,
    required this.textDirection,
    required this.selected,
    required this.onSeek,
    this.syncedChild,
  });

  @override
  State<LyricsInteractiveLine> createState() => _LyricsInteractiveLineState();
}

class _LyricsInteractiveLineState extends State<LyricsInteractiveLine> {
  final _lineTooltipController = TooltipController();
  final _lineContentNotifier = ValueNotifier<LyricsTranslationTooltipContent>(
    LyricsTranslationTooltipContent(
      original: '',
      targetLanguage: TranslationService.inst.targetLanguage,
      loading: true,
    ),
  );

  @override
  void dispose() {
    _lineTooltipController.dispose();
    _lineContentNotifier.dispose();
    super.dispose();
  }

  Future<void> _translateWord(String word) async {
    await runLyricsTranslation(
      controller: _lineTooltipController,
      contentNotifier: _lineContentNotifier,
      text: word,
    );
  }

  Future<void> _translateLine() async {
    await runLyricsTranslation(
      controller: _lineTooltipController,
      contentNotifier: _lineContentNotifier,
      text: widget.text,
    );
  }

  Widget _buildPlainWords() {
    final tokens = RegExp(r'\S+|\s+').allMatches(widget.text);
    final spans = <InlineSpan>[];

    for (final match in tokens) {
      final token = match.group(0)!;
      if (RegExp(r'^\s+$').hasMatch(token)) {
        spans.add(TextSpan(text: token));
        continue;
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: _InteractiveWord(
            word: token,
            textStyle: widget.textStyle,
            accentColor: widget.textStyle.color ?? Colors.white,
            onSingleTap: () => _translateWord(token),
            onDoubleTap: _translateLine,
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.textStyle.color ?? Colors.white;
    final child = widget.selected &&
            widget.syncedChild != null &&
            widget.text.isNotEmpty
        ? widget.syncedChild!
        : _buildPlainWords();

    return WidgetTooltip(
      controller: _lineTooltipController,
      triggerMode: WidgetTooltipTriggerMode.manual,
      dismissMode: WidgetTooltipDismissMode.tapAnywhere,
      direction: WidgetTooltipDirection.top,
      messageDecoration: phoenixTranslationTooltipDecoration(accent),
      triangleColor: accent.withValues(alpha: 0.35),
      messagePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      message: ValueListenableBuilder<LyricsTranslationTooltipContent>(
        valueListenable: _lineContentNotifier,
        builder: (context, content, _) => content,
      ),
      child: GestureDetector(
        onLongPress: widget.onSeek,
        onDoubleTap: _translateLine,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}

class _InteractiveWord extends StatefulWidget {
  final String word;
  final TextStyle textStyle;
  final Color accentColor;
  final VoidCallback onSingleTap;
  final VoidCallback onDoubleTap;

  const _InteractiveWord({
    required this.word,
    required this.textStyle,
    required this.accentColor,
    required this.onSingleTap,
    required this.onDoubleTap,
  });

  @override
  State<_InteractiveWord> createState() => _InteractiveWordState();
}

class _InteractiveWordState extends State<_InteractiveWord> {
  final _controller = TooltipController();
  final _contentNotifier = ValueNotifier<LyricsTranslationTooltipContent>(
    LyricsTranslationTooltipContent(
      original: '',
      targetLanguage: TranslationService.inst.targetLanguage,
      loading: true,
    ),
  );

  int _tapCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _contentNotifier.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details) {
    _tapCount++;

    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      if (_tapCount >= 2) {
        widget.onDoubleTap();
      } else if (_tapCount == 1) {
        runLyricsTranslation(
          controller: _controller,
          contentNotifier: _contentNotifier,
          text: widget.word,
        );
      }
      _tapCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetTooltip(
      controller: _controller,
      triggerMode: WidgetTooltipTriggerMode.manual,
      dismissMode: WidgetTooltipDismissMode.tapAnywhere,
      direction: WidgetTooltipDirection.top,
      messageDecoration: phoenixTranslationTooltipDecoration(widget.accentColor),
      triangleColor: widget.accentColor.withValues(alpha: 0.35),
      messagePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      message: ValueListenableBuilder<LyricsTranslationTooltipContent>(
        valueListenable: _contentNotifier,
        builder: (context, content, _) => content,
      ),
      child: RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: {
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer(),
            (instance) {
              instance.onTapUp = _handleTapUp;
            },
          ),
        },
        child: Text(widget.word, style: widget.textStyle),
      ),
    );
  }
}
