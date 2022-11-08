import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'build_time.dart';

Widget buildPanelMenu() =>
    Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildButtonTogglePlayMode(),
          width2,
          watch(GameState.sceneEditable, (bool sceneEditable) => sceneEditable ? EditorUI.buildControlsWeather() : buildWatchBool(GameUI.timeVisible, buildTime)),
          width2,
          buildIconZoom(),
          width2,
          onPressed(
              child: buildIconFullscreen(),
              action:  Engine.fullscreenToggle,
          ),
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

Widget buildIconFullscreen()  =>
  WatchBuilder(Engine.fullScreen, (bool fullscreen) =>
    onPressed(
        action: Engine.fullscreenToggle,
        child: GameUI.buildAtlasIcon(IconType.Fullscreen)
    )
  );

Widget buildIconZoom() =>
   onPressed(
       action: GameActions.toggleZoom,
       child: GameUI.buildAtlasIcon(IconType.Zoom)
   );

Widget buildIconHome() =>
    onPressed(
        action: GameNetwork.disconnect,
        child: GameUI.buildAtlasIcon(IconType.Home)
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
