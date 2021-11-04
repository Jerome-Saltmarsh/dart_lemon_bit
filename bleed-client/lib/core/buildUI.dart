import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/engine/state/size.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/views.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/cupertino.dart';

Widget buildUI(BuildContext context) {
  if (globalSize == null) {
    return buildLoadingScreen();
  }

  if (connecting) {
    return buildViewConnecting();
  } else if (!connected) {
    return buildViewConnect();
  }

  if (state.lobby != null) return center(buildViewJoinedLobby());

  if (game.gameId < 0) {
    // TODO consider case
    return buildViewConnecting();
  }
  if (editMode) return buildEditorUI();

  if (game.playerId < 0) {
    return text(
        "player id is not assigned. player id: ${game.playerId}, game id: ${game.gameId}");
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
}
