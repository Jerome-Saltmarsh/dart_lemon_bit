

import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';

import 'enums.dart';

class WebsiteActions {

  void showDialogChangePublicName(){
    website.state.dialog.value = WebsiteDialog.Change_Public_Name;
  }

  void showDialogAccount(){
    website.state.dialog.value = WebsiteDialog.Account;
  }

  void showDialogWelcome(){
    website.state.dialog.value = WebsiteDialog.Account_Created;
  }

  void showDialogWelcome2(){
    website.state.dialog.value = WebsiteDialog.Welcome_2;
  }

  void showDialogSubscriptionSuccessful(){
    website.state.dialog.value = WebsiteDialog.Subscription_Successful;
  }

  void showDialogSubscriptionStatusChanged(){
    website.state.dialog.value = WebsiteDialog.Subscription_Status_Changed;
  }

  void showDialogSubscriptionRequired(){
    website.state.dialog.value = WebsiteDialog.Subscription_Required;
  }

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