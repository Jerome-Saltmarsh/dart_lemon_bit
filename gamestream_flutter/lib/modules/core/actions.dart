import 'package:bleed_common/GameType.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:gamestream_flutter/control/classes/authentication.dart';
import 'package:gamestream_flutter/gamestream.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/core/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/modules/website/enums.dart';
import 'package:gamestream_flutter/network/instance/websocket.dart';
import 'package:gamestream_flutter/servers.dart';
import 'package:gamestream_flutter/shared_preferences.dart';
import 'package:gamestream_flutter/ui/actions/sign_in_with_facebook.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';

import '../../isometric/particle_emitters.dart';
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
    player.x = -1;
    player.y = -1;
    totalZombies = 0;
    totalPlayers = 0;
    totalProjectiles = 0;
    totalNpcs = 0;
    particleEmitters.clear();
    particles.clear();
    player.gameDialog.value = null;
    player.npcTalkOptions.value = [];
    player.npcTalk.value = null;
    Engine.zoom = 1;
    Engine.redrawCanvas();
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
    throw Exception("No longer supported");
    // print("actions.openStripeCheckout()");
    // final account = core.state.account.value;
    // if (account == null){
    //   core.actions.setError("Account is null");
    //   return;
    // }
    // if (account.subscriptionActive){
    //   core.actions.setError("Premium subscription already active");
    //   return;
    // }
    //
    // core.state.operationStatus.value = OperationStatus.Opening_Secure_Payment_Session;
    // stripeCheckout(
    //     userId: account.userId,
    //     email: account.email
    // );
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

  void deselectGameType(){
    gamestream.gameType.value = null;
  }

  void exitGame() => webSocket.disconnect();

  void leaveLobby() => exitGame();
}

void connectToGameDarkAge() => connectToGame(GameType.Dark_Age);

void connectToGameEditor() => connectToGame(GameType.Editor);

void connectToGameWaves() => connectToGame(GameType.Waves);

void connectToGameSkirmish() => connectToGame(GameType.Skirmish);

void connectToGame(int gameType, [String message = ""]) =>
  connectToRegion(core.state.region.value, '${gameType} $message');