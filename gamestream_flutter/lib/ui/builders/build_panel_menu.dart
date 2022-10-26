import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:golden_ratio/constants.dart';

import 'build_time.dart';

Widget buildPanelMenu() =>
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildButtonTogglePlayMode(),
          width8,
          buildWatchBool(GameUI.timeVisible, buildTime),
          onPressed(
              child: buildToggleFullscreen(),
              action:  Engine.fullscreenToggle),
          onPressed(
              child: buildButtonExit(),
              action: GameNetwork.disconnect,
          ),
        ]
    );

Widget buildButtonTogglePlayMode() {
  return watch(GameState.sceneEditable, (bool isOwner) {
    if (!isOwner) return const SizedBox();
    return watch(GameState.edit, (bool edit) {
      return container(
          toolTip: "Tab",
          child: edit ? "PLAY" : "EDIT",
          action: GameActions.actionToggleEdit,
          color: GameColors.green,
          alignment: Alignment.center,
          width: 100);
    });
  });
}

Widget buildButtonShowMap() => Tooltip(
    message: ("(M)"), child: text("Map", onPressed: GameState.actionGameDialogShowMap));

Widget buildToggleFullscreen() {
  return WatchBuilder(Engine.fullScreen, (bool fullscreen) {
    return buildAtlasImageButton(
        image: GameImages.icons,
        srcX: 80,
        srcY: 0,
        srcWidth: 48,
        srcHeight: 48,
        scale: goldenRatio_0618,
        action: Engine.fullscreenToggle,
    );
  });
}

Widget buildButtonExit() =>
    buildAtlasImageButton(
      image: GameImages.icons,
      srcX: 80,
      srcY: 48,
      srcWidth: 48,
      srcHeight: 48,
      action: GameNetwork.disconnect,
      scale: 0.75
  );

Widget buildButtonToggleAudio() {
  return onPressed(
    child: WatchBuilder(GameAudio.soundEnabled, (bool soundEnabled) {
      return soundEnabled
          ? Tooltip(child: text("Disable Sound"), message: 'Disable Sound')
          : Tooltip(
              child: text("Enable Sound"), message: 'Enable Sound');
    }),
  );
}
