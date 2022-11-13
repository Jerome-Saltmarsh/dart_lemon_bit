import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'build_time.dart';

Widget buildPanelMenu() =>
    GameUI.buildDialogUIControl(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buildButtonTogglePlayMode(),
            width2,
            watch(ServerState.sceneEditable, (bool sceneEditable) => sceneEditable ? EditorUI.buildRowWeatherControls() : buildWatchBool(GameUI.timeVisible, buildTime)),
            width2,
            GameUI.buildIconZoom(),
            width2,
            onPressed(
                child: GameUI.buildIconFullscreen(),
                action:  Engine.fullscreenToggle,
            ),
            onPressed(
                child: GameUI.buildIconHome(),
                action: GameNetwork.disconnect,
            ),
          ]
      ),
    );

Widget buildButtonTogglePlayMode() {
  return watch(ServerState.sceneEditable, (bool isOwner) {
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
