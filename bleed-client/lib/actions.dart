
import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/editor/enums.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/enums/OperationStatus.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/stripe.dart';
import 'package:bleed_client/ui/actions/signInWithFacebook.dart';
import 'package:bleed_client/ui/ui.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:bleed_client/website/enums.dart';
import 'package:flutter/services.dart';
import 'package:lemon_dispatch/instance.dart';

import 'classes/Authentication.dart';
import 'common/GameType.dart';

final _Actions actions = _Actions();

class _Actions {

  void showEditorDialogSave(){
    print("actions.showEditorDialogSave()");
    editor.state.dialog.value = EditorDialog.Save;
  }

  void updateTileRender(){
    print("actions.updateTileRender()");
    setBakeMapToAmbientLight();
    mapTilesToSrcAndDst();
  }

  void showEditorDialogLoadMap(){
    print("actions.showDialogSelectMap()");
    editor.state.dialog.value = EditorDialog.Load;
  }

  void cancelSubscription() async {
    print("actions.cancelSubscription()");
    actions.showDialogAccount();
    final account = game.account.value;
    if (account == null) {
      actions.showErrorMessage('Account is null');
      return;
    }
    game.operationStatus.value = OperationStatus.Cancelling_Subscription;
    await firestoreService.cancelSubscription(account.userId);
    await updateAccount();
    game.operationStatus.value = OperationStatus.None;
  }

  void logout() {
    print("actions.logout()");
    game.operationStatus.value = OperationStatus.Logging_Out;

    firebaseAuth.signOut().catchError(print);
    googleSignIn.signOut().catchError((error){
      print(error);
    });

    storage.forgetAuthorization();
    game.account.value = null;
    Future.delayed(Duration(seconds: 1), (){
      game.operationStatus.value = OperationStatus.None;
    });
  }

  void showDialogChangePublicName(){
    game.dialog.value = WebsiteDialog.Change_Public_Name;
  }

  void showDialogAccount(){
    game.dialog.value = WebsiteDialog.Account;
  }

  void showDialogWelcome(){
    game.dialog.value = WebsiteDialog.Account_Created;
  }

  void showDialogWelcome2(){
    game.dialog.value = WebsiteDialog.Welcome_2;
  }

  void showDialogSubscriptionSuccessful(){
    game.dialog.value = WebsiteDialog.Subscription_Successful;
  }

  void showDialogSubscriptionStatusChanged(){
    game.dialog.value = WebsiteDialog.Subscription_Status_Changed;
  }

  void showDialogSubscriptionRequired(){
    game.dialog.value = WebsiteDialog.Subscription_Required;
  }

  void loginWithGoogle() async {
    print("actions.loginWithGoogle()");
    game.operationStatus.value = OperationStatus.Authenticating;
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
    game.operationStatus.value = OperationStatus.None;
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

  void setModePlay() {
    print("actions.setModePlay()");
    game.mode.value = game.mode.value = Mode.Play;
  }

  void openMapEditor(){
    editor.actions.newScene();
    game.mode.value = Mode.Edit;
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
    game.dialog.value = WebsiteDialog.Login;
  }

  void showDialogGames(){
    game.dialog.value = WebsiteDialog.Games;
  }

  void store(String key, dynamic value){
    storage.put(key, value);
  }

  void showDialogSubscription(){
    game.dialog.value = WebsiteDialog.Account;
  }

  void openStripeCheckout() {
    print("actions.openStripeCheckout()");
    final account = game.account.value;
    if (account == null){
      showErrorMessage("Account is null");
      return;
    }
    if (account.subscriptionActive){
      showErrorMessage("Premium subscription already active");
      return;
    }

    game.operationStatus.value = OperationStatus.Opening_Secure_Payment_Session;
    stripeCheckout(
        userId: account.userId,
        email: account.email
    );
  }

  void showDialogConfirmCancelSubscription() {
    game.dialog.value = WebsiteDialog.Confirm_Cancel_Subscription;
  }

  void showErrorMessage(String message){
    game.errorMessage.value = message;
  }

  void disconnect(){
    print("actions.disconnect()");
    clearState();
    webSocket.disconnect();
  }

  void changeAccountPublicName(String value) async {
    print("actions.changePublicName('$value')");
    final account = game.account.value;
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
    game.operationStatus.value = OperationStatus.Changing_Public_Name;
    final response = await firestoreService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      showErrorMessage(error.toString());
      throw error;
    });
    game.operationStatus.value = OperationStatus.None;

    switch (response) {
      case ChangeNameStatus.Success:
        updateAccount();
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

  Future updateAccount() async {
    print("refreshAccountDetails()");
    final account = game.account.value;
    if (account == null){
      return;
    }

    game.operationStatus.value = OperationStatus.Updating_Account;
    game.account.value = await firestoreService.findUserById(account.userId).catchError((error){
      pub(LoginException(error));
      return null;
    });
    game.operationStatus.value = OperationStatus.None;
  }

  Future signInOrCreateAccount({
    required String userId,
    required String email,
    required String privateName
  }) async {
    print("actions.signInOrCreateAccount()");
    game.operationStatus.value = OperationStatus.Authenticating;
    final account = await firestoreService.findUserById(userId).catchError((error){
      pub(LoginException(error));
      throw error;
    });
    if (account == null){
      print("No account found. Creating new account");
      game.operationStatus.value = OperationStatus.Creating_Account;
      await firestoreService.createAccount(userId: userId, email: email, privateName: privateName);
      game.operationStatus.value = OperationStatus.Authenticating;
      game.account.value = await firestoreService.findUserById(userId);
      if (game.account.value == null){
        throw Exception("failed to find new account");
      }
      game.dialog.value = WebsiteDialog.Account_Created;
    }else{
      print("Existing Account found");
      game.account.value = account;
    }
    game.operationStatus.value = OperationStatus.None;
  }
}