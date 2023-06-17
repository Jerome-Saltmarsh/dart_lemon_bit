
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/account/account_service.dart';
import 'package:gamestream_flutter/gamestream/network/functions/detect_connection_region.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enums/operation_status.dart';
import 'game.dart';
import 'games.dart';
import 'isometric/enums/dialog_type.dart';
import 'isometric/isometric.dart';
import 'network/enums/connection_region.dart';
import 'network/enums/connection_status.dart';
import 'network/game_network.dart';
import 'server_response_reader.dart';

class Gamestream {

   final audio = GameAudio();
   final animation = GameAnimation();
   final operationStatus = Watch(OperationStatus.None);
   final isometric = Isometric();

   late final io = GameIO(isometric);
   late final gameType = Watch(GameType.Website, onChanged: _onChangedGameType);
   late final game = Watch<Game>(games.website, onChanged: _onChangedGame);
   late final error = Watch<GameError?>(null, onChanged: _onChangedGameError);
   late final account = Watch<Account?>(null, onChanged: onChangedAccount);
   late final accountService = AccountService(this);
   late final ServerResponseReader serverResponseReader;
   late final GameNetwork network;
   late final Games games;

   void refreshGame(){
     _onChangedGameType(gameType.value);
   }

  Gamestream() {
    games = Games(this);
    network = GameNetwork(this);
    network.connectionStatus.onChanged(onChangedNetworkConnectionStatus);
    serverResponseReader = ServerResponseReader(
        gamestream: this,
        isometric: isometric,
    );
  }

   Future init(SharedPreferences sharedPreferences) async {
     print("environment: ${engine.isLocalHost ? 'localhost' : 'production'}");

     final visitDateTimeString = sharedPreferences.getString('visit-datetime');
     if (visitDateTimeString != null) {
       final visitDateTime = DateTime.parse(visitDateTimeString);
       final durationSinceLastVisit = DateTime.now().difference(visitDateTime);
       print("duration since last visit: ${durationSinceLastVisit.inSeconds} seconds");
       WebsiteActions.saveVisitDateTime();
       if (durationSinceLastVisit.inSeconds > 45){
         WebsiteActions.checkForLatestVersion();
         return;
       }
     }

     print("time zone: ${detectConnectionRegion()}");
     engine.onScreenSizeChanged = onScreenSizeChanged;
     engine.deviceType.onChanged(onDeviceTypeChanged);
     GameImages.loadImages();
     engine.cursorType.value = CursorType.Basic;
     io.detectInputMode();

     error.onChanged((GameError? error) {
         if (error == null) return;

         final controller = ScaffoldMessenger.of(engine.buildContext).showSnackBar(
           SnackBar(
             content: text(error.name),
             duration: const Duration(milliseconds: 500),
           ),
         );

         controller.closed.then((value) {
            if (error == this.error.value){
              this.error.value = null;
            }
         });
     });

     games.website.errorMessageEnabled.value = true;

     final visitCount = sharedPreferences.getInt('visit-count');
     if (visitCount == null){
       sharedPreferences.putAny('visit-count', 1);
       games.website.visitCount.value = 1;
     } else {
       sharedPreferences.putAny('visit-count', visitCount + 1);
       games.website.visitCount.value = visitCount + 1;

       final cachedVersion = sharedPreferences.getString('version');
       if (cachedVersion != null){
         if (version != cachedVersion){
           print("New version detected (previous: $cachedVersion, latest: $version)");
         }
       }

       network.region.value = engine.isLocalHost ? ConnectionRegion.LocalHost : ConnectionRegion.Asia_South;
       // GameNetwork.connectToGameAeon();
     }
     await Future.delayed(const Duration(seconds: 4));
   }

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGame(Game game) {
     engine.onDrawCanvas = game.drawCanvas;
     engine.onDrawForeground = game.renderForeground;
     engine.onUpdate = game.update;
     engine.buildUI = game.buildUI;
     engine.onLeftClicked = game.onLeftClicked;
     engine.onRightClicked = game.onRightClicked;
     engine.onKeyPressed = game.onKeyPressed;
     game.onActivated();
   }

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGameType(GameType value) {
     print("_onChangedGameType(${value.name})");
     game.value = switch (value) {
       GameType.Website => games.website,
       GameType.Fight2D => games.fight2D,
       GameType.Combat  => games.isometric,
       GameType.Cube3D  => games.cube3D,
       GameType.Capture_The_Flag => games.captureTheFlag,
       _ => throw Exception('mapGameTypeToGame($gameType)')
     };
   }

   void onScreenSizeChanged(
       double previousWidth,
       double previousHeight,
       double newWidth,
       double newHeight,
       ) => io.detectInputMode();

   void onDeviceTypeChanged(int deviceType){
     io.detectInputMode();
   }

   void startGameType(GameType gameType){
      if (gameType.isSinglePlayer) {
        this.gameType.value = gameType;
        return;
      }
      network.connectToGame(gameType);
   }

   void disconnect(){
      if (gameType.value.isSinglePlayer){
        gameType.value = GameType.Website;
      } else {
        network.disconnect();
      }
   }

   void onError(Object error, StackTrace stack) {
     if (error.toString().contains('NotAllowedError')){
       // https://developer.chrome.com/blog/autoplay/
       // This error appears when the game attempts to fullscreen
       // without the user having interacted first
       // TODO dispatch event on fullscreen failed
       isometric.events.onErrorFullscreenAuto();
       return;
     }
     print(error.toString());
     print(stack);
     WebsiteState.error.value = error.toString();
   }

   void _onChangedGameError(GameError? gameError){
     print("_onChangedGameError($gameError)");
     if (gameError == null) return;
     gamestream.isometric.clientState.playAudioError();
     switch (gameError) {
       case GameError.Unable_To_Join_Game:
         WebsiteState.error.value = 'unable to join game';
         network.disconnect();
         break;
       default:
         break;
     }
   }

   void onChangedAccount(Account? account) {
     if (account == null) return;
     final flag = 'subscription_status_${account.userId}';
     if (storage.contains(flag)){
       final storedSubscriptionStatusString = storage.get<String>(flag);
       final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
     }
   }

   void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
     engine.onDrawForeground = null;
     serverResponseReader.bufferSizeTotal.value = 0;

     switch (connection) {
       case ConnectionStatus.Connected:
         engine.cursorType.value = CursorType.None;
         engine.drawCanvasAfterUpdate = true;
         engine.zoomOnScroll = true;
         engine.zoom = 1.0;
         engine.targetZoom = 1.0;
         isometric.ui.hoverDialogType.value = DialogType.None;
         isometric.clientState.timeConnectionEstablished = DateTime.now();
         audio.enabledSound.value = true;
         if (!engine.isLocalHost) {
           engine.fullScreenEnter();
         }
         break;

       case ConnectionStatus.Done:
         engine.cameraX = 0;
         engine.cameraY = 0;
         engine.zoom = 1.0;
         engine.drawCanvasAfterUpdate = true;
         engine.cursorType.value = CursorType.Basic;
         engine.drawCanvasAfterUpdate = true;
         engine.fullScreenExit();
         isometric.player.active.value = false;
         isometric.clientState.timeConnectionEstablished = null;
         isometric.clientState.clear();
         isometric.server.clean();
         isometric.server.sceneEditable.value = false;
         gameType.value = GameType.Website;
         audio.enabledSound.value = false;
         break;
       case ConnectionStatus.Failed_To_Connect:
         WebsiteState.error.value = "Failed to connect";
         break;
       case ConnectionStatus.Invalid_Connection:
         WebsiteState.error.value = "Invalid Connection";
         break;
       case ConnectionStatus.Error:
         WebsiteState.error.value = "Connection Error";
         break;
       default:
         break;
     }
   }

}