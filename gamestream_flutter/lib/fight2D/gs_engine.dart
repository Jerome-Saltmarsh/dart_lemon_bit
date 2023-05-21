import 'package:gamestream_flutter/fight2D/game.dart';
import 'package:gamestream_flutter/fight2D/game_combat.dart';
import 'package:gamestream_flutter/fight2D/game_fight2d.dart';
import 'package:gamestream_flutter/game_utils.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/fight2D/game_website.dart' as gw;
import 'package:shared_preferences/shared_preferences.dart';

final gsEngine = GSEngine();

class GSEngine {
   late final gameWebsite = gw.GameWebsite();
   late final gameType = Watch(GameType.Website, onChanged: _onChangedGameType);
   late final game = Watch<Game>(gameWebsite, onChanged: _onChangedGame);

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
     GameIO.addListeners();
     GameIO.detectInputMode();

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
     // if (game == null) {
     //   Engine.onDrawForeground = null;
     //   Engine.onDrawCanvas = null;
     //   Engine.buildUI = GameWebsite.buildUI;
     //   GameAudio.musicStop();
     //   Engine.fullScreenExit();
     //   return;
     // }
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
       GameType.Website => gw.GameWebsite(),
       GameType.Fight2D => GameFight2D(),
       GameType.Combat => GameCombat(),
       _ => throw Exception('mapGameTypeToGame($gameType)')
     };
   }

   static void onScreenSizeChanged(
       double previousWidth,
       double previousHeight,
       double newWidth,
       double newHeight,
       ) => GameIO.detectInputMode();

   static void onDeviceTypeChanged(int deviceType){
     GameIO.detectInputMode();
   }
}