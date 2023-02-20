import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import '../scene/generate_empty_scene.dart';

class GameDarkAgeEditor extends Game {

  @override
  int get gameType => GameType.Editor;

  GameDarkAgeEditor({Scene? scene}) : super(
      scene: scene ?? generateEmptyScene(),
      environment: GameEnvironment(),
      time: GameTime(),
      gameType: GameType.Editor,
      options: GameOptions(
        perks: false,
        inventory: false,
        items: false,
      ),
  );

  @override
  void customUpdate(){
    environment.update();
  }

  @override
  void customOnPlayerDisconnected(Player player) {
      removeFromEngine();
  }

  @override
  void customOnPlayerRevived(Player player) {
     if (isSafeToRevive(25, 25)){
       // player.indexColumn = 25;
       // player.indexRow = 25;
       // player.indexZ = 8;
       Game.setGridPosition(position: player, z: 4, row: 25, column: 25);
       player.state = CharacterState.Idle;
       return;
     }

     for (var row = 0; row < scene.gridRows; row++) {
        for (var column = 0; column < scene.gridColumns; column++){
          if (isSafeToRevive(row, column)){
            // player.indexColumn = column;
            // player.indexRow = row;
            // player.indexZ = 8;
            Game.setGridPosition(position: player, z: 4, row: row, column: column);
            return;
          }
        }
     }
  }

  bool isSafeToRevive(int row, int column) {
     for (var z = scene.gridHeight - 1; z >= 0; z--){
       final type = scene.getGridType(z, row, column);
        if (type == NodeType.Water) return false;
        if (type == NodeType.Water_Flowing) return false;
     }
     return true;
  }
}