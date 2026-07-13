import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lrc/lrc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phoenix/src/beginning/utilities/constants.dart';
import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_controller.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_state.dart';
import 'package:phoenix/src/beginning/widgets/lyrics/lyrics_lrc_parsed_view.dart';
import 'package:phoenix/src/beginning/widgets/now_art.dart';

class LyricsPanel extends StatelessWidget {
  final ScrollController? plainScrollController;
  final EdgeInsetsGeometry? plainPadding;
  final bool showArtWhenNoLyrics;
  final bool allowFullscreen;
  final bool compactArt;

  const LyricsPanel({
    super.key,
    this.plainScrollController,
    this.plainPadding,
    this.showArtWhenNoLyrics = false,
    this.allowFullscreen = true,
    this.compactArt = false,
  });

  Color _textColor() {
    if (!(musicBox.get('dynamicArtDB') ?? true)) return kMaterialBlack;
    if (isArtworkDark ?? true) return Colors.white;
    return Colors.black;
  }

  Color _highlightColor() {
    return _textColor().withValues(alpha: 0.18);
  }

  double _fontSize() {
    final width = deviceWidth ?? 400;
    return width / 18;
  }

  Widget _artBackground() {
    return NowArt(compactArt);
  }

  Widget _plainLyrics(String text) {
    return SingleChildScrollView(
      controller: plainScrollController,
      padding: plainPadding ?? EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          wordSpacing: 2,
          fontSize: _fontSize(),
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w600,
          color: _textColor(),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    final controller = LyricsController.inst;
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: dialogueAnimationDuration,
        reverseDuration: dialogueAnimationDuration,
        child: _LyricsFullscreenPage(
          lrc: controller.synced,
          plainText: controller.plainText,
          textColor: _textColor(),
          highlightColor: _highlightColor(),
          fontSize: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LyricsController.inst,
      builder: (context, _) {
        final controller = LyricsController.inst;
        final current = controller.current;

        if (current.mode == LyricsMode.loading) {
          return Center(
            child: Text(
              current.statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _fontSize(),
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w600,
                color: _textColor(),
              ),
            ),
          );
        }

        if (current.mode == LyricsMode.synced && controller.synced != null) {
          return LyricsLRCParsedView(
            lrc: controller.synced,
            plainText: controller.plainText,
            background: _artBackground(),
            textColor: _textColor(),
            highlightColor: _highlightColor(),
            fontSize: _fontSize(),
            canShowToggleFullscreenButton: allowFullscreen,
            onFullscreenTap: () => _openFullscreen(context),
          );
        }

        final text = controller.displayText.trim();
        if (text.isEmpty || text == "Couldn't find any matching lyrics.") {
          if (showArtWhenNoLyrics) return _artBackground();
          return Center(
            child: Text(
              text.isEmpty
                  ? "Couldn't find any matching lyrics."
                  : text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _fontSize(),
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w600,
                color: _textColor(),
              ),
            ),
          );
        }

        return _plainLyrics(text);
      },
    );
  }
}

class _LyricsFullscreenPage extends StatelessWidget {
  final Lrc? lrc;
  final String plainText;
  final Color textColor;
  final Color highlightColor;
  final double fontSize;

  const _LyricsFullscreenPage({
    required this.lrc,
    required this.plainText,
    required this.textColor,
    required this.highlightColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          nowMediaItem.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (art != null)
            Image.memory(
              art!,
              fit: BoxFit.cover,
            ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),
          SafeArea(
            child: LyricsLRCParsedView(
              lrc: lrc,
              plainText: plainText,
              isFullScreenView: true,
              background: const SizedBox.shrink(),
              textColor: textColor,
              highlightColor: highlightColor,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
