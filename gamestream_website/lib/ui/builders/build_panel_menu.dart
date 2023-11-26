import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_map.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../colours.dart';
import 'build_time.dart';

Widget buildPanelMenu() {
  return buildPanel(
      child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      buildButtonTogglePlayMode(),
      width8,
      buildTime(),
      width8,
      buildButtonToggleFullscreen(),
      width8,
      buildButtonExit(),
    ],
  ));
}

Widget buildButtonTogglePlayMode() {
  return watch(sceneMetaDataMapEditable, (bool isOwner) {
    if (!isOwner) return const SizedBox();
    return watch(playMode, (mode) {
      return container(
          toolTip: "Tab",
          child: mode == Mode.Play ? "EDIT" : "PLAY",
          action: actionPlayModeToggle,
          color: green,
          alignment: Alignment.center,
          width: 100);
    });
  });
}

Widget buildButtonShowMap() => Tooltip(
    message: ("(M)"), child: text("Map", onPressed: actionGameDialogShowMap));

Widget buildButtonToggleFullscreen() {
  return onPressed(
    callback: engine.fullscreenToggle,
    child: WatchBuilder(engine.fullScreen, (bool fullscreen) {
      return fullscreen
          ? Tooltip(
              child: icons.symbols.fullscreenEnter, message: 'Exit Fullscreen')
          : Tooltip(
              child: icons.symbols.fullscreenExit, message: 'Enter Fullscreen');
    }),
  );
}

Widget buildButtonExit() {
  return onPressed(
    callback: core.actions.exitGame,
    child: Tooltip(child: icons.symbols.home, message: 'EXIT'),
  );
}

Widget buildButtonToggleAudio() {
  return onPressed(
    callback: audio.toggleSoundEnabled,
    child: WatchBuilder(audio.soundEnabled, (bool soundEnabled) {
      return soundEnabled
          ? Tooltip(child: icons.symbols.soundEnabled, message: 'Disable Sound')
          : Tooltip(
              child: icons.symbols.soundDisabled, message: 'Enable Sound');
    }),
  );
}
