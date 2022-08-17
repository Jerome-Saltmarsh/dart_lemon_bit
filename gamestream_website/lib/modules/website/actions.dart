

import 'package:gamestream_flutter/modules/modules.dart';

import 'enums.dart';

class WebsiteActions {

  void showDialogChangePublicName(){
    website.state.dialog.value = WebsiteDialog.Change_Public_Name;
  }

  void showDialogConfirmCancelSubscription() {
    website.state.dialog.value = WebsiteDialog.Confirm_Cancel_Subscription;
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
    // game.type.value = GameType.Custom;
    // game.customGameName = customGame;
    // connectToWebSocketServer(core.state.region.value, GameType.Custom);
  }

  void _log(String value){
    print("website.actions.$value()");
  }

  void showDialogChangeRegion(){
    website.state.dialog.value = WebsiteDialog.Change_Region;
  }

  void showDialogSubscription(){
    website.state.dialog.value = WebsiteDialog.Account;
  }

  void showDialogLogin(){
    website.state.dialog.value = WebsiteDialog.Login;
  }

  void showDialogGames(){
    website.state.dialog.value = WebsiteDialog.Games;
  }
}

