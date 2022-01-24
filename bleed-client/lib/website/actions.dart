

import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/core/module.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/website/website.dart';

import 'enums.dart';

class WebsiteActions {

  void showDialogCustomMaps(){
    _log("showDialogCustomMaps");
    website.state.dialog.value = WebsiteDialog.Custom_Maps;
  }

  void connectToCustomGame(String customGame){
    _log("connectToCustomGame");
    game.type.value = GameType.Custom;
    game.customGameName = customGame;
    connectToWebSocketServer(core.state.region.value, GameType.Custom);
  }

  void _log(String value){
    print("website.actions.$value()");
  }

  void showDialogChangeRegion(){
    website.state.dialog.value = WebsiteDialog.Change_Region;
  }
}