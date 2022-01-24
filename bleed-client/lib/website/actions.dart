

import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/state/game.dart';

import 'enums.dart';

class WebsiteActions {

  void showDialogCustomMaps(){
    _log("showDialogCustomMaps");
    game.dialog.value = WebsiteDialog.Custom_Maps;
  }

  void connectToCustomGame(String customGame){
    _log("connectToCustomGame");
    game.type.value = GameType.Custom;
    game.customGameName = customGame;
    connectToWebSocketServer(game.region.value, GameType.Custom);
  }

  void _log(String value){
    print("website.actions.$value()");
  }
}