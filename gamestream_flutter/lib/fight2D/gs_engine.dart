import 'package:gamestream_flutter/fight2D/game.dart';
import 'package:gamestream_flutter/fight2D/game_combat.dart';
import 'package:gamestream_flutter/fight2D/game_fight2d.dart';
import 'package:gamestream_flutter/library.dart';

final gsEngine = GSEngine();

class GSEngine {
   late final gameType = Watch<int?>(null, onChanged: _onChangedGameType);
   late final game = Watch<Game?>(null, onChanged: _onChangedGame);

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGame(Game? game){
     if (game == null){
       Engine.onDrawForeground = null;
       Engine.onDrawCanvas = null;
       Engine.buildUI = GameWebsite.buildUI;
       GameAudio.musicStop();
       Engine.fullScreenExit();
       return;
     }
     Engine.onDrawCanvas = game.drawCanvas;
     Engine.onDrawForeground = game.renderForeground;
     Engine.onUpdate = game.update;
     Engine.buildUI = game.buildUI;
     game.onActivated();
   }

   /// EVENT HANDLER (DO NOT CALL)
   void _onChangedGameType(int? value) {
     game.value = switch (value) {
       GameType.Fight2D => GameFight2D(),
       GameType.Combat => GameCombat(),
       null => null,
       _ => throw Exception('mapGameTypeToGame($gameType)')
     };
   }
}