import 'dart:io';
import 'dart:isolate';

import 'package:desktop_lyric/component/desktop_lyric_body.dart';
import 'package:desktop_lyric/component/foreground.dart';
import 'package:desktop_lyric/component/unlock_overlay.dart';
import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/desktop_lyric_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:win32/win32.dart' as win32;

class ActionRow extends StatelessWidget {
  const ActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();
    const spacer = SizedBox(width: 8);

    final textDisplayController = context.watch<TextDisplayController>();
    final onSurface = Color(theme.onSurface);

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () async {
              final className = win32.TEXT("FLUTTER_RUNNER_WIN32_WINDOW");
              final windowName = win32.TEXT("desktop_lyric");
              final found = win32.FindWindow(className, windowName);
              win32.free(className);
              win32.free(windowName);

              hWnd = found != 0 ? found : win32.GetForegroundWindow();

              if (hWnd != null) {
                final exStyle = win32.GetWindowLongPtr(
                  hWnd!,
                  win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
                );

                win32.SetWindowLongPtr(
                  hWnd!,
                  win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
                  exStyle |
                      win32.WINDOW_EX_STYLE.WS_EX_LAYERED |
                      win32.WINDOW_EX_STYLE.WS_EX_TRANSPARENT,
                );

                stdout.write(
                  const ControlEventMessage(ControlEvent.lock)
                      .buildMessageJson(),
                );

                Isolate.run(() => showUnlockOverlay(hWnd!));
              }
            },
            color: onSurface,
            icon: const Icon(Icons.lock),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: textDisplayController.increaseLyricFontSize,
              color: onSurface,
              icon: const Icon(Icons.text_increase),
            ),
            spacer,
            IconButton(
              onPressed: textDisplayController.decreaseLyricFontSize,
              color: onSurface,
              icon: const Icon(Icons.text_decrease),
            ),
            spacer,
            IconButton(
              onPressed: textDisplayController.toggleLyricTranslation,
              tooltip: textDisplayController.showLyricTranslation
                  ? "歌词翻译：显示"
                  : "歌词翻译：隐藏",
              color: textDisplayController.showLyricTranslation
                  ? onSurface
                  : onSurface.withValues(alpha: 0.5),
              icon: const Icon(Icons.translate),
            ),
            spacer,
            IconButton(
              onPressed: textDisplayController.switchLyricTextAlign,
              tooltip: "切换歌词对齐方向",
              color: onSurface,
              icon: Icon(
                switch (textDisplayController.lyricTextAlign) {
                  LyricTextAlign.left => Icons.format_align_left,
                  LyricTextAlign.center => Icons.format_align_center,
                  LyricTextAlign.right => Icons.format_align_right,
                },
              ),
            ),
            spacer,
            IconButton(
              onPressed: () => textDisplayController.increaseFontWeight(),
              onLongPress: () =>
                  textDisplayController.increaseFontWeight(smallStep: true),
              tooltip: "增加字体粗细 (${textDisplayController.lyricFontWeight})",
              color: onSurface,
              icon: Text(
                "B+",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            spacer,
            IconButton(
              onPressed: () => textDisplayController.decreaseFontWeight(),
              onLongPress: () =>
                  textDisplayController.decreaseFontWeight(smallStep: true),
              tooltip: "减小字体粗细 (${textDisplayController.lyricFontWeight})",
              color: onSurface,
              icon: Text(
                "B-",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            spacer,
            IconButton(
              onPressed: textDisplayController.toggleNowPlayingInfo,
              tooltip: textDisplayController.showNowPlayingInfo
                  ? "关闭曲目信息"
                  : "显示曲目信息",
              color: onSurface,
              icon: Icon(
                textDisplayController.showNowPlayingInfo
                    ? Icons.info_outline
                    : Icons.info,
              ),
            ),
            spacer,
            IconButton(
              onPressed: textDisplayController.toggleDoubleLineMode,
              tooltip: textDisplayController.doubleLineMode ? "双行模式" : "单行模式",
              color: onSurface,
              icon: Icon(
                textDisplayController.doubleLineMode
                    ? Icons.view_agenda
                    : Icons.view_headline,
              ),
            ),
            spacer,
            IconButton(
              onPressed: () {
                stdout.write(
                  const ControlEventMessage(ControlEvent.previousAudio)
                      .buildMessageJson(),
                );
              },
              color: onSurface,
              icon: const Icon(Icons.skip_previous),
            ),
            spacer,
            ValueListenableBuilder(
              valueListenable: DesktopLyricController.instance.isPlaying,
              builder: (context, isPlaying, _) => IconButton(
                onPressed: () {
                  stdout.write(
                    ControlEventMessage(
                      isPlaying ? ControlEvent.pause : ControlEvent.start,
                    ).buildMessageJson(),
                  );
                },
                color: onSurface,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ),
            spacer,
            IconButton(
              onPressed: () {
                stdout.write(
                  const ControlEventMessage(ControlEvent.nextAudio)
                      .buildMessageJson(),
                );
              },
              color: onSurface,
              icon: const Icon(Icons.skip_next),
            ),
            spacer,
            const _ShowColorSelectorBtn(),
            spacer,
            IconButton(
              onPressed: () {
                stdout.write(
                  const ControlEventMessage(ControlEvent.close)
                      .buildMessageJson(),
                );
              },
              color: onSurface,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}

final _COLOR_SELECTOR_CONTROLLER = MenuController();

class _ShowColorSelectorBtn extends StatelessWidget {
  const _ShowColorSelectorBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();
    final onSurface = Color(theme.onSurface);
    return MenuAnchor(
      controller: _COLOR_SELECTOR_CONTROLLER,
      consumeOutsideTap: true,
      onOpen: () {
        ALWAYS_SHOW_ACTION_ROW = true;
      },
      onClose: () {
        ALWAYS_SHOW_ACTION_ROW = false;
      },
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Color(theme.surfaceContainer)),
        elevation: const WidgetStatePropertyAll(8),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            "背景不透明度",
            style: TextStyle(color: onSurface),
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            thumbColor: Color(theme.primary),
            overlayColor: Color(theme.primary).withOpacity(0.08),
            activeTrackColor: Color(theme.primary),
            inactiveTrackColor: Color(theme.primary).withOpacity(0.15),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: ValueListenableBuilder(
            valueListenable: BACKGROUND_OPACITY,
            builder: (context, opacity, _) => Slider(
              value: opacity,
              onChanged: (newOpacity) {
                BACKGROUND_OPACITY.value = newOpacity;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            "文字颜色",
            style: TextStyle(color: onSurface),
          ),
        ),
        Wrap(
          children: List.generate(
            Colors.primaries.length,
            (i) => _ColorTile(color: Colors.primaries[i]),
          ),
        )
      ],
      builder: (context, controller, _) => IconButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        color: Color(theme.onSurface),
        icon: const Icon(Icons.palette),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final Color color;
  const _ColorTile({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final textDisplayController = context.watch<TextDisplayController>();
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Ink(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: InkWell(
          onTap: () {
            if (textDisplayController.hasSpecifiedColor) {
              if (textDisplayController.specifiedColor == color) {
                textDisplayController.usePlayerTheme();
              } else {
                textDisplayController.spcifiyColor(color);
              }
            } else {
              textDisplayController.spcifiyColor(color);
            }

            _COLOR_SELECTOR_CONTROLLER.close();
          },
          child: textDisplayController.hasSpecifiedColor &&
                  textDisplayController.specifiedColor == color
              ? const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 16))
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
