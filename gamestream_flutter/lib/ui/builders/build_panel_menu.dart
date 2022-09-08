import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_map.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';
import 'package:golden_ratio/constants.dart';
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
      onPressed(
          child: buildToggleFullscreen(),
          action:  engine.fullscreenToggle),
      onPressed(
          child: buildButtonExit(),
          action: () {
            core.actions.exitGame();
          }
      ),
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

Widget buildToggleFullscreen() {
  return WatchBuilder(engine.fullScreen, (bool fullscreen) {
    return buildCanvasImageButton(
        srcX: 80,
        srcY: 0,
        srcWidth: 48,
        srcHeight: 48,
        scale: goldenRatio_0618,
        action: engine.fullscreenToggle,
    );
  });
}

Widget buildButtonExit() =>
    buildCanvasImageButton(
      srcX: 80,
      srcY: 48,
      srcWidth: 48,
      srcHeight: 48,
      action: core.actions.exitGame,
      scale: 0.75
  );

Widget buildButtonToggleAudio() {
  return onPressed(
    action: audio.toggleSoundEnabled,
    child: WatchBuilder(audio.soundEnabled, (bool soundEnabled) {
      return soundEnabled
          ? Tooltip(child: text("Disable Sound"), message: 'Disable Sound')
          : Tooltip(
              child: text("Enable Sound"), message: 'Enable Sound');
    }),
  );
}
