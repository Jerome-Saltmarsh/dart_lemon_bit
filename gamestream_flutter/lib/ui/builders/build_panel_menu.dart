import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_map.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'build_time.dart';

Widget buildPanelMenu() {
  return buildPanel(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildTime(),
          buildButtonShowMap(),
          buildButtonToggleFullscreen(),
          // buildButtonToggleAudio(),
          buildButtonExit(),
        ],
    )
  );
}

Widget buildButtonShowMap() => Tooltip(
    message: ("(M)"),
    child: text("Map", onPressed: actionGameDialogShowMap));

Widget buildButtonToggleFullscreen() {
  return onPressed(
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
        );
}

Widget buildButtonExit() {
  return onPressed(
          callback: core.actions.exitGame,
          child: Tooltip(
              child: icons.symbols.home,
              message: 'EXIT'
          ),
        );
}

Widget buildButtonToggleAudio() {
  return onPressed(
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
        );
}
