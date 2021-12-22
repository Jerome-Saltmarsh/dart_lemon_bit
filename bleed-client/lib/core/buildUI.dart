import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/views.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_engine/state/size.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildUI(BuildContext context) {
  return WatchBuilder(connection, (Connection connection){

    if (globalSize == null) {
      print("globalSize == null - showing loading screen");
      return buildLoadingScreen();
    }

    if (connection == Connection.Connecting) {
      return buildViewConnecting();
    } else if (!connected) {
      return buildViewConnect();
    }

    if (game.id < 0) {
      // TODO consider case
      return buildViewConnecting();
    }
    if (editMode) return buildEditorUI();

    if (game.player.id < 0) {
      return text(
          "player id is not assigned. player id: ${game.player.id}, game id: ${game.id}");
    }

    if (framesSinceEvent > 30) {
      return Container(
        width: globalSize.width,
        height: globalSize.height,
        alignment: Alignment.center,
        child: Container(child: text("Reconnecting...", fontSize: 30)),
      );
    }
    if (!playerAssigned) {
      return Container(
        width: globalSize.width,
        height: globalSize.height,
        alignment: Alignment.center,
        child: text("Error: No Player Assigned"),
      );
    }

    try {
      return buildHud();
    } catch (error) {
      print("error build hud");
      return text("an error occurred");
    }

  });
}
