import 'package:desktop_lyric/component/foreground.dart';
import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/desktop_lyric_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LyricLineDisplayArea extends StatelessWidget {
  const LyricLineDisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    final textDisplayController = context.watch<TextDisplayController>();
    final theme = context.watch<ThemeChangedMessage>();

    final textColor = textDisplayController.hasSpecifiedColor
        ? textDisplayController.specifiedColor
        : Color(theme.primary);
    final textAlign = switch (textDisplayController.lyricTextAlign) {
      LyricTextAlign.left => TextAlign.left,
      LyricTextAlign.center => TextAlign.center,
      LyricTextAlign.right => TextAlign.right,
    };
    final crossAxisAlignment = switch (textDisplayController.lyricTextAlign) {
      LyricTextAlign.left => CrossAxisAlignment.start,
      LyricTextAlign.center => CrossAxisAlignment.center,
      LyricTextAlign.right => CrossAxisAlignment.end,
    };

    return ValueListenableBuilder(
      valueListenable: DesktopLyricController.instance.lyricLine,
      builder: (context, lyricLine, _) {
        final contentText = Text(
          lyricLine.content,
          style: TextStyle(
            color: textColor,
            fontSize: textDisplayController.lyricFontSize,
            fontWeight:
                lyricFontWeightFromInt(textDisplayController.lyricFontWeight),
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        );

        return Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            outlinedText(
              key: LYRIC_TEXT_KEY,
              text: lyricLine.content,
              style: contentText.style!,
              outlineColor: lyricOutlineColor(textColor),
              outlineWidth: lyricOutlineWidth(textDisplayController.lyricFontSize),
              maxLines: 1,
              overflow: TextOverflow.clip,
              textAlign: textAlign,
              softWrap: false,
            ),
            if (textDisplayController.showLyricTranslation &&
                lyricLine.translation != null)
              outlinedText(
                key: TRANSLATION_TEXT_KEY,
                text: lyricLine.translation!,
                style: TextStyle(
                  color: textColor,
                  fontSize: textDisplayController.translationFontSize,
                  fontWeight: lyricFontWeightFromInt(
                    textDisplayController.lyricFontWeight,
                  ),
                ),
                outlineColor: lyricOutlineColor(textColor),
                outlineWidth:
                    lyricOutlineWidth(textDisplayController.translationFontSize),
                maxLines: 1,
                overflow: TextOverflow.clip,
                textAlign: textAlign,
                softWrap: false,
              ),
          ],
        );
      },
    );
  }
}
