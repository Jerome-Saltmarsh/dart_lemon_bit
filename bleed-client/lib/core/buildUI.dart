import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/network.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/buildHomePage.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/compose/views.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/watches/mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_engine/state/size.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildUI(BuildContext context) {

  if (globalSize == null) {
    return buildLoadingScreen();
  }

  return WatchBuilder(game.serverType, (ServerType serverType){
    if (serverType == ServerType.None){
      return buildSelectServer();
    }

    return WatchBuilder(game.type, (GameType type) {
      if (type == GameType.None) {
        return buildHomePage();
      }

      return WatchBuilder(connection, (Connection connection){

        if (connection == Connection.Connecting) {
          return buildViewConnecting();
        } else if (!connected) {
          return buildSelectServer();
        }

        switch(connection) {
          case Connection.None:
            return text("Connection.None");
          case Connection.Connecting:
            return buildViewConnecting();
          case Connection.Connected:
            return buildHud();
          case Connection.Done:
            return text("Connection.Done");
          case Connection.Error:
            return text("Connection.Error");
          case Connection.Failed_To_Connect:
            return text("Connection.Failed_To_Connect");
          default:
            throw Exception();
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
      });
    });
  });
}
