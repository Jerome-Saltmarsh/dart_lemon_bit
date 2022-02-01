import 'package:bleed_client/classes/Authentication.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/servers.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/core/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/modules/website/enums.dart';
import 'package:bleed_client/server/server.dart';
import 'package:bleed_client/services/authService.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:bleed_client/stripe.dart';
import 'package:bleed_client/ui/actions/signInWithFacebook.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/user-service-client/firestoreService.dart';
import 'package:bleed_client/webSocket.dart';
import 'package:flutter/services.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

import 'exceptions.dart';

class CoreActions {

  CoreState get state => core.state;

  void operationCompleted(){
    state.operationStatus.value = OperationStatus.None;
  }

  void setError(String message){
    state.error.value = message;
  }

  void clearError(){
    state.error.value = null;
  }

  void changeAccountPublicName(String value) async {
    print("actions.changePublicName('$value')");
    final account = core.state.account.value;
    if (account == null) {
      setError("Account is null");
      return;
    }
    value = value.trim();

    if (value == account.publicName){
      return;
    }

    if (value.isEmpty) {
      setError("Name entered is empty");
      return;
    }
    core.state.operationStatus.value = OperationStatus.Changing_Public_Name;
    final response = await firestoreService
        .changePublicName(userId: account.userId, publicName: value)
        .catchError((error) {
      setError(error.toString());
      throw error;
    });
    core.state.operationStatus.value = OperationStatus.None;

    switch (response) {
      case ChangeNameStatus.Success:
        core.actions.updateAccount();
        website.actions.showDialogAccount();
        setError("Name Changed successfully");
        break;
      case ChangeNameStatus.Taken:
        setError("'$value' already taken");
        break;
      case ChangeNameStatus.Too_Short:
        setError("Too short");
        break;
      case ChangeNameStatus.Too_Long:
        setError("Too long");
        break;
      case ChangeNameStatus.Other:
        setError("Something went wrong");
        break;
    }
  }

  void cancelSubscription() async {
    print("actions.cancelSubscription()");
    website.actions.showDialogAccount();
    final account = core.state.account.value;
    if (account == null) {
      setError('Account is null');
      return;
    }
    core.state.operationStatus.value = OperationStatus.Cancelling_Subscription;
    await firestoreService.cancelSubscription(account.userId);
    await updateAccount();
    core.state.operationStatus.value = OperationStatus.None;
  }

  Future updateAccount() async {
    print("refreshAccountDetails()");
    final account = core.state.account.value;
    if (account == null){
      return;
    }

    core.state.operationStatus.value = OperationStatus.Updating_Account;
    core.state.account.value = await firestoreService.findUserById(account.userId).catchError((error){
      pub(LoginException(error));
      return null;
    });
    core.state.operationStatus.value = OperationStatus.None;
  }

  void logout() {
    print("actions.logout()");
    core.state.operationStatus.value = OperationStatus.Logging_Out;

    try {
      firebaseAuth.signOut().catchError(print);
      googleSignIn.signOut().catchError((error) {
        print(error);
      });
    }catch(e){
      print(e);
    }

    storage.forgetAuthorization();
    core.state.account.value = null;
    Future.delayed(Duration(seconds: 1), (){
      core.state.operationStatus.value = OperationStatus.None;
    });
  }

  void loginWithGoogle() async {
    print("core.actions.loginWithGoogle()");
    core.state.operationStatus.value = OperationStatus.Authenticating;
    await getGoogleAuthentication().then(login).catchError((error){
      if (error is PlatformException){
        if (error.code == "popup_closed_by_user"){
          return;
        }
        setError(error.code);
        return;
      }
      setError(error.toString());
    });
    core.state.operationStatus.value = OperationStatus.None;
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


  void disconnect(){
    print("actions.disconnect()");
    clearState();
    webSocket.disconnect();
  }

  void clearState() {
    print('clearState()');
    clearCompileGameState();
    isometric.state.paths.clear();
    engine.state.zoom = 1;
    game.gameEvents.clear();
    core.state.mode.value = Mode.Player;
    refreshUI();
    engine.actions.redrawCanvas();
  }

  void clearCompileGameState() {
    modules.game.state.player.id = -1;
    game.id = -1;
    modules.game.state.player.uuid.value = "";
    modules.game.state.player.x = -1;
    modules.game.state.player.y = -1;
    game.totalZombies.value = 0;
    game.totalHumans = 0;
    game.totalProjectiles = 0;
    game.grenades.clear();
    game.collectables.clear();
    game.particleEmitters.clear();

    for (Vector2 bullet in game.bulletHoles) {
      bullet.x = 0;
      bullet.y = 0;
    }

    for (Particle particle in isometric.state.particles) {
      particle.active = false;
    }

    for (Vector2 bullet in game.bulletHoles) {
      bullet.x = 0;
      bullet.y = 0;
    }
    game.bulletHoleIndex = 0;
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
      // TODO Illegal reference to website
      website.state.dialog.value = WebsiteDialog.Account_Created;
    }else{
      print("Existing Account found");
      core.state.account.value = account;
    }
    core.state.operationStatus.value = OperationStatus.None;
  }


  void openStripeCheckout() {
    print("actions.openStripeCheckout()");
    final account = core.state.account.value;
    if (account == null){
      core.actions.setError("Account is null");
      return;
    }
    if (account.subscriptionActive){
      core.actions.setError("Premium subscription already active");
      return;
    }

    core.state.operationStatus.value = OperationStatus.Opening_Secure_Payment_Session;
    stripeCheckout(
        userId: account.userId,
        email: account.email
    );
  }

  void store(String key, dynamic value){
    storage.put(key, value);
  }


  void loginWithFacebook() async {
    final facebookAuthentication = await getAuthenticationFacebook();
    if (facebookAuthentication == null){
      return;
    }
    login(facebookAuthentication);
  }

  void closeErrorMessage(){
    print("actions.closeErrorMessage()");
    core.state.error.value = null;
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
    core.state.mode.value = core.state.mode.value == Mode.Player ? Mode.Editor : Mode.Player;
  }

  void setModePlay() {
    print("actions.setModePlay()");
    core.state.mode.value = core.state.mode.value = Mode.Player;
  }

  void openMapEditor(){
    core.state.mode.value = Mode.Editor;
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
    modules.game.state.player.uuid.value = "";
  }
}