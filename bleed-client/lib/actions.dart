
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/modules/website/enums.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/stripe.dart';
import 'package:bleed_client/ui/actions/signInWithFacebook.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/services.dart';
import 'package:lemon_dispatch/instance.dart';

import 'classes/Authentication.dart';
import 'common/GameType.dart';

final _Actions actions = _Actions();

class _Actions {

  void logout() {
    print("actions.logout()");
    core.state.operationStatus.value = OperationStatus.Logging_Out;

    firebaseAuth.signOut().catchError(print);
    googleSignIn.signOut().catchError((error){
      print(error);
    });

    storage.forgetAuthorization();
    core.state.account.value = null;
    Future.delayed(Duration(seconds: 1), (){
      core.state.operationStatus.value = OperationStatus.None;
    });
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

  void loginWithGoogle() async {
    print("actions.loginWithGoogle()");
    core.state.operationStatus.value = OperationStatus.Authenticating;
    await getGoogleAuthentication().then(login).catchError((error){
      if (error is PlatformException){
        if (error.code == "popup_closed_by_user"){
          return;
        }
        showErrorMessage(error.code);
        return;
      }
      showErrorMessage(error.toString());
    });
    core.state.operationStatus.value = OperationStatus.None;
  }

  void loginWithFacebook() async {
    final facebookAuthentication = await getAuthenticationFacebook();
    if (facebookAuthentication == null){
      return;
    }
    login(facebookAuthentication);
  }

  Future login(Authentication authentication){
    print("actions.login()");
    storage.rememberAuthorization(authentication);
    return signInOrCreateAccount(
        userId: authentication.userId,
        email: authentication.email,
        privateName: authentication.name
    );
  }

  void closeErrorMessage(){
    print("actions.closeErrorMessage()");
    core.state.errorMessage.value = null;
  }

  void play(GameType gameType){
    game.type.value = gameType;
    connectToWebSocketServer(core.state.region.value, gameType);
  }

  void connectToSelectedGame(){
    connectToWebSocketServer(core.state.region.value, game.type.value);
  }

  void deselectGameType(){
    game.type.value = GameType.None;
  }

  void toggleAudio() {
    game.settings.audioMuted.value = !game.settings.audioMuted.value;
  }

  void toggleEditMode() {
    core.state.mode.value = core.state.mode.value == Mode.Play ? Mode.Edit : Mode.Play;
  }

  void setModePlay() {
    print("actions.setModePlay()");
    core.state.mode.value = core.state.mode.value = Mode.Play;
  }

  void openMapEditor(){
    editor.actions.newScene();
    core.state.mode.value = Mode.Edit;
  }

  void exitGame(){
    print("logic.exit()");
    game.type.value = GameType.None;
    clearSession();
    webSocket.disconnect();
  }

  // functions
  void leaveLobby() {
    server.leaveLobby();
    exitGame();
  }

  void clearSession(){
    print("logic.clearSession()");
    game.player.uuid.value = "";
  }

  void showDialogLogin(){
    website.state.dialog.value = WebsiteDialog.Login;
  }

  void showDialogGames(){
    website.state.dialog.value = WebsiteDialog.Games;
  }

  void store(String key, dynamic value){
    storage.put(key, value);
  }

  void showDialogSubscription(){
    website.state.dialog.value = WebsiteDialog.Account;
  }

  void openStripeCheckout() {
    print("actions.openStripeCheckout()");
    final account = core.state.account.value;
    if (account == null){
      showErrorMessage("Account is null");
      return;
    }
    if (account.subscriptionActive){
      showErrorMessage("Premium subscription already active");
      return;
    }

    core.state.operationStatus.value = OperationStatus.Opening_Secure_Payment_Session;
    stripeCheckout(
        userId: account.userId,
        email: account.email
    );
  }

  void showDialogConfirmCancelSubscription() {
    website.state.dialog.value = WebsiteDialog.Confirm_Cancel_Subscription;
  }

  void showErrorMessage(String message){
    core.state.errorMessage.value = message;
  }

  void disconnect(){
    print("actions.disconnect()");
    clearState();
    webSocket.disconnect();
  }

  void changeAccountPublicName(String value) async {
    print("actions.changePublicName('$value')");
    final account = core.state.account.value;
    if (account == null) {
      showErrorMessage("Account is null");
      return;
    }
    value = value.trim();

    if (value == account.publicName){
      return;
    }

    if (value.isEmpty) {
      showErrorMessage("Name entered is empty");
      return;
    }
    core.state.operationStatus.value = OperationStatus.Changing_Public_Name;
    final response = await firestoreService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      showErrorMessage(error.toString());
      throw error;
    });
    core.state.operationStatus.value = OperationStatus.None;

    switch (response) {
      case ChangeNameStatus.Success:
        core.actions.updateAccount();
        showDialogAccount();
        showErrorMessage("Name Changed successfully");
        break;
      case ChangeNameStatus.Taken:
        showErrorMessage("'$value' already taken");
        break;
      case ChangeNameStatus.Too_Short:
        showErrorMessage("Too short");
        break;
      case ChangeNameStatus.Too_Long:
        showErrorMessage("Too long");
        break;
      case ChangeNameStatus.Other:
        showErrorMessage("Something went wrong");
        break;
    }
  }

  Future signInOrCreateAccount({
    required String userId,
    required String email,
    required String privateName
  }) async {
    print("actions.signInOrCreateAccount()");
    core.state.operationStatus.value = OperationStatus.Authenticating;
    final account = await firestoreService.findUserById(userId).catchError((error){
      pub(LoginException(error));
      throw error;
    });
    if (account == null){
      print("No account found. Creating new account");
      core.state.operationStatus.value = OperationStatus.Creating_Account;
      await firestoreService.createAccount(userId: userId, email: email, privateName: privateName);
      core.state.operationStatus.value = OperationStatus.Authenticating;
      core.state.account.value = await firestoreService.findUserById(userId);
      if (core.state.account.value == null){
        throw Exception("failed to find new account");
      }
      website.state.dialog.value = WebsiteDialog.Account_Created;
    }else{
      print("Existing Account found");
      core.state.account.value = account;
    }
    core.state.operationStatus.value = OperationStatus.None;
  }
}