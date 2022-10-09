import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_map.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/game.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../colours.dart';
import 'build_time.dart';

Widget buildPanelMenu() =>
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildButtonTogglePlayMode(),
          width8,
          buildWatchBool(game.timeVisible, buildTime),
          onPressed(
              child: buildToggleFullscreen(),
              action:  engine.fullscreenToggle),
          onPressed(
              child: buildButtonExit(),
              action: () {
                core.actions.exitGame();
              }
          ),
        ]
    );


Widget buildButtonTogglePlayMode() {
  return watch(sceneEditable, (bool isOwner) {
    if (!isOwner) return const SizedBox();
    return watch(game.edit, (bool edit) {
      return container(
          toolTip: "Tab",
          child: edit ? "PLAY" : "EDIT",
          action: actionToggleEdit,
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
    return buildAtlasImageButton(
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
    buildAtlasImageButton(
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
