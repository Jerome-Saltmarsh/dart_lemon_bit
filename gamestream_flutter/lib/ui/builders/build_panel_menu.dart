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
            watch(GameAudio.muted, (bool t) => text("Audio Enabled: ${!t}", onPressed: GameAudio.toggleMuted)),
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
    return watch(ClientState.edit, (bool edit) {
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

