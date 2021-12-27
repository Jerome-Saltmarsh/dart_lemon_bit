import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/enums/Region.dart';
import 'package:bleed_client/logic.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/buildHomePage.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildUI(BuildContext context) {

  return WatchBuilder(game.region, (Region serverType){
    if (serverType == Region.None){
      return views.selectRegion;
    }

    return WatchBuilder(game.type, (GameType gameType) {
      if (gameType == GameType.None) {
        return buildRegion();
      }

      return WatchBuilder(webSocket.connection, (Connection connection){
        switch(connection) {
          case Connection.Connecting:
            return buildConnecting();
          case Connection.Connected:
            return buildConnected(gameType);
          default:
            return center(Column(
              mainAxisAlignment: axis.main.center,
              children: [
                text(connection),
                height8,
                button("Cancel", logic.exit, minWidth: 100)
              ],
            ));
        }

        // todo check framesSinceEvent
      });
    });
  });
}

