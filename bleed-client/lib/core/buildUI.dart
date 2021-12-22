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
import 'package:bleed_client/ui/state/flutter_constants.dart';
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
      return buildSelectServerType();
    }

    return WatchBuilder(game.type, (GameType type) {
      if (type == GameType.None) {
        return buildHomePage();
      }

      return WatchBuilder(connection, (Connection connection){
        switch(connection) {
          case Connection.Connecting:
            return buildConnecting();
          case Connection.Connected:
            return buildConnected();
          default:
            return center(Column(
              mainAxisAlignment: main.center,
              children: [
                text(connection),
                height8,
                button("Cancel", game.exit, minWidth: 100)
              ],
            ));
        }

        // todo check framesSinceEvent
      });
    });
  });
}
