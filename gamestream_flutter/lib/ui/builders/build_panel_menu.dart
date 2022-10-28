import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'build_time.dart';

Widget buildPanelMenu() =>
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildButtonTogglePlayMode(),
          width8,
          watch(GameState.sceneEditable, (bool sceneEditable) => sceneEditable ? EditorUI.buildControlTime() : buildWatchBool(GameUI.timeVisible, buildTime)),
          onPressed(
              child: buildIconFullscreen(),
              action:  Engine.fullscreenToggle),
          onPressed(
              child: buildIconHome(),
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

Widget buildIconFullscreen() {
  return WatchBuilder(Engine.fullScreen, (bool fullscreen) {
    return buildAtlasImageButton(
        image: GameImages.atlasIcons,
        srcX: AtlasIconsX.Fullscreen,
        srcY: AtlasIconsY.Fullscreen,
        srcWidth: AtlasIconSize.Fullscreen,
        srcHeight: AtlasIconSize.Fullscreen,
        scale: Engine.GoldenRatio_0_618,
        action: Engine.fullscreenToggle,
    );
  });
}

Widget buildIconHome() =>
    buildAtlasImageButton(
      image: GameImages.atlasIcons,
      srcX: AtlasIconsX.Home,
      srcY: AtlasIconsY.Home,
      srcWidth: AtlasIconSize.Home,
      srcHeight: AtlasIconSize.Home,
      action: GameNetwork.disconnect,
      scale: Engine.GoldenRatio_0_618,
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
