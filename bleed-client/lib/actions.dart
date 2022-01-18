
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/functions/resetTiles.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/stripe.dart';
import 'package:bleed_client/ui/ui.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:bleed_client/webSocket.dart';

import 'common/GameType.dart';

final _Actions actions = _Actions();

class _Actions {

  void cancelSubscription() async {
    print("actions.cancelSubscription()");
    actions.showDialogAccount();
    final account = game.account.value;
    if (account == null) {
      actions.showErrorMessage('Account is null');
      return;
    }
    game.operationStatus.value = OperationStatus.Cancelling_Subscription;
    await userService.cancelSubscription(account.userId);
    await updateAccount();
    game.operationStatus.value = OperationStatus.None;
  }

  void logout() {
    print("signOut()");
    signOut();
  }

  void showDialogChangePublicName(){
    game.dialog.value = Dialogs.Change_Public_Name;
  }

  void showDialogAccount(){
    game.dialog.value = Dialogs.Account;
  }

  void showDialogWelcome(){
    game.dialog.value = Dialogs.Account_Created;
  }

  void showDialogWelcome2(){
    game.dialog.value = Dialogs.Welcome_2;
  }

  void showDialogSubscriptionSuccessful(){
    game.dialog.value = Dialogs.Subscription_Successful;
  }

  void showDialogSubscriptionStatusChanged(){
    game.dialog.value = Dialogs.Subscription_Status_Changed;
  }

  void closeErrorMessage(){
    game.errorMessage.value = null;
  }

  void play(GameType gameType){
    game.type.value = gameType;
    connectToWebSocketServer(game.region.value, gameType);
  }

  void connectToSelectedGame(){
    connectToWebSocketServer(game.region.value, game.type.value);
  }

  void deselectGameType(){
    game.type.value = GameType.None;
  }

  void toggleAudio() {
    game.settings.audioMuted.value = !game.settings.audioMuted.value;
  }

  void toggleEditMode() {
    game.mode.value = game.mode.value == Mode.Play ? Mode.Edit : Mode.Play;
  }

  void openEditor(){
    newScene(rows: 40, columns: 40);
    game.mode.value = Mode.Edit;

  }

  void exit(){
    print("logic.exit()");
    game.type.value = GameType.None;
    clearSession();
    webSocket.disconnect();
  }

  // functions
  void leaveLobby() {
    server.leaveLobby();
    exit();
  }

  void clearSession(){
    print("logic.clearSession()");
    game.player.uuid.value = "";
  }

  void showDialogLogin(){
    game.dialog.value = Dialogs.Login;
  }

  void showDialogGames(){
    game.dialog.value = Dialogs.Games;
  }

  void showDialogSubscription(){
    game.dialog.value = Dialogs.Account;
  }

  void openStripeCheckout() {
    print("openStripeCheckout()");
    final account = game.account.value;
    if (account == null){
      throw Exception("Cannot open stripe checkout, account is null");
    }
    if (account.subscriptionActive){
      actions.showErrorMessage("This account already has an active premium subscription");
      return;
    }

    game.operationStatus.value = OperationStatus.Opening_Secure_Payment_Session;
    stripeCheckout(
        userId: authentication.value!.userId,
        email: authentication.value!.email
    );
  }

  void showDialogConfirmCancelSubscription() {
    game.dialog.value = Dialogs.Confirm_Cancel_Subscription;
  }

  void showErrorMessage(String message){
    game.errorMessage.value = message;
  }

  void changeAccountPublicName(String value) async {
    print("actions.changePublicName('$value')");
     final account = game.account.value;
     if (account == null) {
       showErrorMessage("Account is null");
       return;
     }
     value = value.trim();
     if (value.isEmpty){
       showErrorMessage("Name entered is empty");
       return;
     }
     final response = await userService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      showErrorMessage(error.toString());
      throw error;
    });

     switch(response){
       case ChangeNameStatus.Success:
         showErrorMessage("Name Changed successfully");
         break;
       case ChangeNameStatus.Taken:
         showErrorMessage("'$value' already taken");
         break;
       case ChangeNameStatus.Too_Short:
         showErrorMessage("At least 7 characters long");
         break;
       case ChangeNameStatus.Too_Long:
         showErrorMessage("At least 7 characters long");
         break;
       case ChangeNameStatus.Other:
         showErrorMessage("Something went wrong");
         break;
     }
  }
}