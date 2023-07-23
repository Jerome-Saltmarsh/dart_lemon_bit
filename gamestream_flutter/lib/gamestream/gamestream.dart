
import 'package:archive/archive.dart';
import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/classes/template_animation.dart';
import 'package:gamestream_flutter/gamestream/network/functions/detect_connection_region.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game.dart';
import 'games.dart';
import 'isometric/atlases/atlas.dart';
import 'isometric/isometric.dart';
import 'isometric/ui/isometric_colors.dart';
import 'network/enums/connection_region.dart';
import 'network/enums/connection_status.dart';
import 'network/game_network.dart';
import 'operation_status.dart';

class Gamestream extends StatelessWidget with ByteReader {
  var previousServerResponse = -1;
  var renderResponse = false;
  var clearErrorTimer = -1;

  final serverFPS = Watch(0);
  final bufferSize = Watch(0);
  final bufferSizeTotal = Watch(0);
  final decoder = ZLibDecoder();
  final audio = GameAudio();
  final operationStatus = Watch(OperationStatus.None);
  final isometric = Isometric();

  late final Engine engine;
  late final updateFrame = Watch(0, onChanged: onChangedUpdateFrame);
  late final io = GameIO(isometric);
  late final gameType = Watch(GameType.Website, onChanged: onChangedGameType);
  late final game = Watch<Game>(games.website, onChanged: _onChangedGame);
  late final error = Watch<GameError?>(null, onChanged: _onChangedGameError);
  late final account = Watch<Account?>(null, onChanged: onChangedAccount);
  late final GameNetwork network;
  late final Games games;
  late final rendersSinceUpdate = Watch(0, onChanged: gamestream.isometric.events.onChangedRendersSinceUpdate);
  var engineBuilt = false;

  Gamestream() {
    print('GameStream()');
    games = Games(this);
    network = GameNetwork(this);
    network.connectionStatus.onChanged(onChangedNetworkConnectionStatus);
  }

   Future init(SharedPreferences sharedPreferences) async {
     print('gamestream.init()');
     print("environment: ${engine.isLocalHost ? 'localhost' : 'production'}");

     final visitDateTimeString = sharedPreferences.getString('visit-datetime');
     if (visitDateTimeString != null) {
       final visitDateTime = DateTime.parse(visitDateTimeString);
       final durationSinceLastVisit = DateTime.now().difference(visitDateTime);
       print('duration since last visit: ${durationSinceLastVisit.inSeconds} seconds');
       games.website.saveVisitDateTime();
       if (durationSinceLastVisit.inSeconds > 45){
         games.website.checkForLatestVersion();
         return;
       }
     }

     print('time zone: ${detectConnectionRegion()}');
     engine.onScreenSizeChanged = onScreenSizeChanged;
     engine.deviceType.onChanged(onDeviceTypeChanged);
     engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
     engine.drawCanvasAfterUpdate = false;
     renderResponse = true;
     Images.loadImages();
     engine.cursorType.value = CursorType.Basic;
     io.detectInputMode();

     for (final entry in GameObjectType.Collection.entries){
       final type = entry.key;
       final values = entry.value;
       final atlas = Atlas.SrcCollection[type];
       for (final value in values){
         if (!atlas.containsKey(value)){
           // print('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
           throw Exception('missing atlas src for ${GameObjectType.getName(type)} ${GameObjectType.getNameSubType(type, value)}');
         }
       }
     }

     for (final weaponType in WeaponType.values){
       try {
         TemplateAnimation.getWeaponPerformAnimation(weaponType);
       } catch (e){
         print('attack animation missing for ${GameObjectType.getNameSubType(GameObjectType.Weapon, weaponType)}');
       }
     }

     error.onChanged((GameError? error) {
         if (error == null) return;
         game.value.onGameError(error);
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
           print('New version detected (previous: $cachedVersion, latest: $version)');
         }
       }

       network.region.value = engine.isLocalHost ? ConnectionRegion.LocalHost : ConnectionRegion.Asia_South;
     }
     await Future.delayed(const Duration(seconds: 4));
   }

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGame(Game game) {
     engine.onDrawCanvas = game.drawCanvas;
     engine.onDrawForeground = game.renderForeground;
     engine.buildUI = game.buildUI;
     engine.onLeftClicked = game.onLeftClicked;
     engine.onRightClicked = game.onRightClicked;
     engine.onKeyPressed = game.onKeyPressed;
     engine.onMouseEnterCanvas = game.onMouseEnter;
     engine.onMouseExitCanvas = game.onMouseExit;
     game.onActivated();
   }

   void onChangedGameType(GameType value) {
     print('onChangedGameType(${value.name})');
     io.reset();
     startGameByType(value);
   }

   void startGameByType(GameType gameType){
     game.value = games.mapGameTypeToGame(gameType);
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
      network.connectToGame(gameType);
   }

   void disconnect(){
     network.disconnect();
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
     gamestream.games.website.error.value = error.toString();
   }

   void _onChangedGameError(GameError? gameError){
     print('_onChangedGameError($gameError)');
     if (gameError == null)
       return;

     clearErrorTimer = 300;
     isometric.client.playAudioError();
     switch (gameError) {
       case GameError.Unable_To_Join_Game:
         gamestream.games.website.error.value = 'unable to join game';
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
     bufferSizeTotal.value = 0;

     switch (connection) {
       case ConnectionStatus.Connected:
         engine.cursorType.value = CursorType.None;
         engine.zoomOnScroll = true;
         engine.zoom = 1.0;
         engine.targetZoom = 1.0;
         // gamestream.isometric.ui.mouseOverDialog.setFalse();
         isometric.client.timeConnectionEstablished = DateTime.now();
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
         engine.fullScreenExit();
         isometric.player.active.value = false;
         isometric.client.timeConnectionEstablished = null;
         isometric.client.clear();
         isometric.clean();
         isometric.gameObjects.clear();
         isometric.sceneEditable.value = false;
         gameType.value = GameType.Website;
         audio.enabledSound.value = false;
         break;
       case ConnectionStatus.Failed_To_Connect:
         gamestream.games.website.error.value = 'Failed to connect';
         break;
       case ConnectionStatus.Invalid_Connection:
         gamestream.games.website.error.value = 'Invalid Connection';
         break;
       case ConnectionStatus.Error:
         gamestream.games.website.error.value = 'Connection Error';
         break;
       default:
         break;
     }
   }

  void onChangedUpdateFrame(int value){
    rendersSinceUpdate.value = 0;
  }

  void update(){
    updateClearErrorTimer();
    game.value.update();
  }

  void updateClearErrorTimer() {
    if (clearErrorTimer <= 0)
      return;

    clearErrorTimer--;
    if (clearErrorTimer > 0)
      return;

    error.value = null;
  }

  void render(Canvas canvas, Size size){

  }

  @override
  Widget build(BuildContext context) {
     print('gamestream.build()');

     if (engineBuilt){
       return engine;
     }

     engineBuilt = true;
     engine = Engine(
      init: init,
      update: update,
      render: render,
      title: 'AMULET',
      themeData: ThemeData(fontFamily: 'VT323-Regular'),
      backgroundColor: IsometricColors.black,
      onError: onError,
      buildUI: games.website.buildUI,
      buildLoadingScreen: games.website.buildLoadingPage,
    );
    return engine;
  }
}