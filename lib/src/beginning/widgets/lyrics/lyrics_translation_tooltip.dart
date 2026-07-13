import 'package:flutter/material.dart';
import 'package:phoenix/src/beginning/utilities/constants.dart';
import 'package:phoenix/src/beginning/utilities/translation/deepl_languages.dart';
import 'package:phoenix/src/beginning/utilities/translation/translation_service.dart';
import 'package:widget_tooltip/widget_tooltip.dart';

class LyricsTranslationTooltipContent extends StatelessWidget {
  final String original;
  final String? translated;
  final String? errorMessage;
  final bool loading;
  final DeeplLanguage targetLanguage;

  const LyricsTranslationTooltipContent({
    super.key,
    required this.original,
    required this.targetLanguage,
    this.translated,
    this.errorMessage,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                targetLanguage.flag,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                targetLanguage.name,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            original,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 13,
              color: Colors.white54,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          if (loading)
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 14,
                color: Colors.orangeAccent,
              ),
            )
          else
            Text(
              translated ?? '',
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }
}

BoxDecoration phoenixTranslationTooltipDecoration(Color accent) {
  return BoxDecoration(
    color: kMaterialBlack.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(kRounded),
    border: Border.all(color: accent.withValues(alpha: 0.35)),
    boxShadow: [
      BoxShadow(
        blurRadius: 16,
        offset: kShadowOffset,
        color: Colors.black.withValues(alpha: 0.45),
      ),
    ],
  );
}

Future<void> runLyricsTranslation({
  required TooltipController controller,
  required ValueNotifier<LyricsTranslationTooltipContent> contentNotifier,
  required String text,
}) async {
  final service = TranslationService.inst;
  contentNotifier.value = LyricsTranslationTooltipContent(
    original: text,
    targetLanguage: service.targetLanguage,
    loading: true,
  );
  controller.show();

  try {
    final result = await service.translate(text);
    contentNotifier.value = LyricsTranslationTooltipContent(
      original: text,
      targetLanguage: service.targetLanguage,
      translated: result.translated,
    );
  } on TranslationException catch (e) {
    contentNotifier.value = LyricsTranslationTooltipContent(
      original: text,
      targetLanguage: service.targetLanguage,
      errorMessage: e.message,
    );
  } catch (_) {
    contentNotifier.value = LyricsTranslationTooltipContent(
      original: text,
      targetLanguage: service.targetLanguage,
      errorMessage: 'Netzwerkfehler',
    );
  }
}
