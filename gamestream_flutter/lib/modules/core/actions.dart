import 'dart:typed_data';

import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/classes/Authentication.dart';
import 'package:bleed_common/GameType.dart';
import 'package:gamestream_flutter/constants/servers.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/services/authService.dart';
import 'package:gamestream_flutter/sharedPreferences.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/stripe.dart';
import 'package:gamestream_flutter/ui/actions/signInWithFacebook.dart';
import 'package:gamestream_flutter/ui/logic/hudLogic.dart';
import 'package:gamestream_flutter/webSocket.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';

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
    }).whenComplete((){
      core.state.operationStatus.value = OperationStatus.None;
    });
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
    // isometric.state.paths.clear();
    engine.zoom = 1;
    game.gameEvents.clear();
    refreshUI();
    isometric.actions.state.tiles.clear();
    isometric.actions.state.tilesDst = Float32List(0);
    isometric.actions.state.tilesSrc = Float32List(0);
    isometric.actions.refreshTileSize();
    engine.redrawCanvas();
  }

  void clearCompileGameState() {
    final player = modules.game.state.player;
    player.id = -1;
    game.id = -1;
    player.uuid.value = "";
    player.x = -1;
    player.y = -1;
    game.totalZombies.value = 0;
    game.totalPlayers.value = 0;
    game.totalProjectiles = 0;
    game.collectables.clear();
    game.bulletHoleIndex = 0;
    isometric.state.particles.clear();
    isometric.state.next = null;

    for (final bullet in game.bulletHoles) {
      bullet.x = 0;
      bullet.y = 0;
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
    print("connectToSelectedGame()");
    connectToWebSocketServer(core.state.region.value, game.type.value);
  }

  void deselectGameType(){
    game.type.value = GameType.None;
  }

  void toggleEditMode() {
    final mode = core.state.mode;
    mode.value = mode.value == Mode.Player ? Mode.Editor : Mode.Player;
  }

  void setModePlay() {
    print("actions.setModePlay()");
    core.state.mode.value = core.state.mode.value = Mode.Player;
  }

  void setModeWebsite() {
    print("actions.setModePlay()");
    core.state.mode.value = core.state.mode.value = Mode.Website;
  }

  void openMapEditor(){
    core.state.mode.value = Mode.Editor;
    modules.isometric.state.hours.value = 12;
    modules.isometric.state.minutes.value = 0;
  }

  void exitGame(){
    print("logic.exit()");
    game.type.value = GameType.None;
    clearSession();
    webSocket.disconnect();
  }

  // functions
  void leaveLobby() {
    exitGame();
  }

  void clearSession(){
    print("logic.clearSession()");
    modules.game.state.player.uuid.value = "";
  }
}