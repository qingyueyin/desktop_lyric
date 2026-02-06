import 'package:desktop_lyric/component/foreground.dart';
import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/desktop_lyric_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NowPlayingInfo extends StatelessWidget {
  const NowPlayingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final textDisplayController = context.watch<TextDisplayController>();
    final theme = context.watch<ThemeChangedMessage>();

    final textColor = textDisplayController.hasSpecifiedColor
        ? textDisplayController.specifiedColor
        : Color(theme.primary);
    final textStyle = DefaultTextStyle.of(context).style.merge(
          TextStyle(
            color: textColor,
            fontWeight: lyricFontWeightFromInt(textDisplayController.lyricFontWeight),
          ),
        );
    final outlineColor = lyricOutlineColor(textColor);

    return ValueListenableBuilder(
      valueListenable: DesktopLyricController.instance.nowPlaying,
      builder: (context, nowPlaying, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            outlinedText(
              text: nowPlaying.title,
              style: textStyle,
              outlineColor: outlineColor,
              outlineWidth: lyricOutlineWidth(textStyle.fontSize ?? 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              softWrap: false,
            ),
            outlinedText(
              text: "${nowPlaying.artist} - ${nowPlaying.album}",
              style: textStyle,
              outlineColor: outlineColor,
              outlineWidth: lyricOutlineWidth(textStyle.fontSize ?? 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              softWrap: false,
            ),
          ],
        );
      },
    );
  }
}
