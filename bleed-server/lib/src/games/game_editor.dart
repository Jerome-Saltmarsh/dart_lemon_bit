import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/classes/src/game_isometric.dart';
import 'package:bleed_server/src/classes/src/game_time.dart';
import '../scene/generate_empty_scene.dart';

class GameEditor extends GameIsometric {

  GameEditor({Scene? scene}) : super(
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
  void customOnPlayerDisconnected(IsometricPlayer player) {
      removeFromEngine();
  }

  @override
  void customOnPlayerRevived(IsometricPlayer player) {
     if (isSafeToRevive(25, 25)) {
       GameIsometric.setGridPosition(position: player, z: 1, row: 25, column: 25);
       player.state = CharacterState.Idle;
       player.writePlayerMoved();
       return;
     }

     for (var row = 0; row < scene.gridRows; row++) {
        for (var column = 0; column < scene.gridColumns; column++){
          if (isSafeToRevive(row, column)){
            GameIsometric.setGridPosition(position: player, z: 1, row: row, column: column);
            player.writePlayerMoved();
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