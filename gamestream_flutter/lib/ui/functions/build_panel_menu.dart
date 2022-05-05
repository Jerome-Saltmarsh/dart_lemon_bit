import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/ui/functions/build_panel.dart';

Widget buildPanelMenu() {
  return buildPanel(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          onPressed(
            callback: engine.fullscreenToggle,
            child: WatchBuilder(engine.fullScreen, (bool fullscreen){
              return fullscreen ?
                Tooltip(
                    child: icons.symbols.fullscreenEnter,
                    message: 'Exit Fullscreen'
                ) :
                Tooltip(
                    child: icons.symbols.fullscreenExit,
                    message: 'Enter Fullscreen'
                );
            }),
          ),
          onPressed(
            callback: audio.toggleSoundEnabled,
            child: WatchBuilder(audio.soundEnabled, (bool soundEnabled) {
              return soundEnabled
                  ? Tooltip(
                      child: icons.symbols.soundEnabled,
                      message: 'Disable Sound')
                  : Tooltip(
                      child: icons.symbols.soundDisabled,
                      message: 'Enable Sound');
      }),
          ),
          onPressed(
            callback: core.actions.exitGame,
            child: Tooltip(
                child: icons.symbols.home,
                message: 'EXIT'
            ),
          ),
        ],
    )
  );
}