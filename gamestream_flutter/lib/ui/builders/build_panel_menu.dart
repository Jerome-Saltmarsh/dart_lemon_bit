import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';

import 'build_time.dart';

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

