
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