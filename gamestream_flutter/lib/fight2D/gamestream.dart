import 'package:gamestream_flutter/fight2D/game.dart';
import 'package:gamestream_flutter/fight2D/game_fight2d.dart';
import 'package:gamestream_flutter/library.dart';

final gsEngine = GSEngine();

class GSEngine {
   late final game = Watch<Game?>(null, onChanged: _onChangedGame);

   void _onChangedGame(Game? game){
     if (game == null){
       Engine.onDrawForeground = null;
       Engine.onDrawCanvas = null;
       return;
     }
     Engine.onDrawCanvas = game.drawCanvas;
     Engine.onDrawForeground = game.renderForeground;
     Engine.onUpdate = game.update;
   }
}

class GameBuilder {

  static Game buildGameById(int gameType) {
    switch(gameType){
      case GameType.Fight2D:
        return GameFight2D();
      case GameType.Combat:
        return GameCombat();
      default:
        throw Exception('mapGameTypeToGame($gameType)');
    }
  }
}