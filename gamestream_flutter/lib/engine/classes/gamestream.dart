import 'package:gamestream_flutter/engine/games/game_aeon.dart';
import 'package:gamestream_flutter/engine/games/game_cube3d.dart';
import 'package:gamestream_flutter/engine/games/game_fight2d.dart';
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/game_utils.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamestream_flutter/engine/games/game_website.dart' as gw;
import 'game.dart';
import '../games/game_combat.dart';


class Gamestream {
   late final gameType = Watch(GameType.Website, onChanged: _onChangedGameType);
   late final game = Watch<Game>(gameWebsite, onChanged: _onChangedGame);
   late final gameWebsite = gw.GameWebsite();

   final io = GameIO();
   final audio = GameAudio();
   final actions = GameActions();

   final serverResponseReader = ServerResponseReader();
   late final GameNetwork network;
   final gameFight2D = GameFight2D();
   final gameCube3D = GameCube3D();

  Gamestream() {
    network = GameNetwork(this);
  }

   Future init(SharedPreferences sharedPreferences) async {
     print("environment: ${Engine.isLocalHost ? 'localhost' : 'production'}");

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

     print("time zone: ${GameUtils.detectConnectionRegion()}");
     Engine.onScreenSizeChanged = onScreenSizeChanged;
     Engine.deviceType.onChanged(onDeviceTypeChanged);
     GameImages.loadImages();
     Engine.cursorType.value = CursorType.Basic;
     gamestream.io.addListeners();
     gamestream.io.detectInputMode();

     if (Engine.isLocalHost) {
       GameWebsite.region.value = ConnectionRegion.LocalHost;
     } else {
       GameWebsite.region.value = GameUtils.detectConnectionRegion();
     }

     GameWebsite.errorMessageEnabled.value = true;

     final visitCount = sharedPreferences.getInt('visit-count');
     if (visitCount == null){
       sharedPreferences.putAny('visit-count', 1);
       GameWebsite.visitCount.value = 1;
     } else {
       sharedPreferences.putAny('visit-count', visitCount + 1);
       GameWebsite.visitCount.value = visitCount + 1;

       final cachedVersion = sharedPreferences.getString('version');
       if (cachedVersion != null){
         if (version != cachedVersion){
           print("New version detected (previous: $cachedVersion, latest: $version)");
         }
       }

       GameWebsite.region.value = Engine.isLocalHost ? ConnectionRegion.LocalHost : ConnectionRegion.Asia_South;
       // GameNetwork.connectToGameAeon();
     }
     await Future.delayed(const Duration(seconds: 4));
   }

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGame(Game game) {
     Engine.onDrawCanvas = game.drawCanvas;
     Engine.onDrawForeground = game.renderForeground;
     Engine.onUpdate = game.update;
     Engine.buildUI = game.buildUI;
     game.onActivated();
   }

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGameType(GameType value) {
     print("_onChangedGameType(${value.name})");
     game.value = switch (value) {
       GameType.Website => gameWebsite,
       GameType.Fight2D => gameFight2D,
       GameType.Combat => GameCombat(),
       GameType.Cube3D => GameCube3D(),
       GameType.Aeon => GameAeon(),
       _ => throw Exception('mapGameTypeToGame($gameType)')
     };
   }

   static void onScreenSizeChanged(
       double previousWidth,
       double previousHeight,
       double newWidth,
       double newHeight,
       ) => gamestream.io.detectInputMode();

   static void onDeviceTypeChanged(int deviceType){
     gamestream.io.detectInputMode();
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

   static void onError(Object error, StackTrace stack) {
     if (error.toString().contains('NotAllowedError')){
       // https://developer.chrome.com/blog/autoplay/
       // This error appears when the game attempts to fullscreen
       // without the user having interacted first
       // TODO dispatch event on fullscreen failed
       GameEvents.onErrorFullscreenAuto();
       return;
     }
     print(error.toString());
     print(stack);
     WebsiteState.error.value = error.toString();
   }
}