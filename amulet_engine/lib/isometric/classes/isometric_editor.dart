
import 'package:amulet_common/src.dart';

import '../functions/src.dart';
import 'isometric_environment.dart';
import 'isometric_game.dart';
import 'isometric_player.dart';
import 'isometric_time.dart';
import 'scene.dart';

class IsometricEditor extends IsometricGame {

  IsometricEditor({Scene? scene}) : super(
      scene: scene ?? generateEmptyScene(),
      environment: IsometricEnvironment(),
      time: IsometricTime(),
  );

  @override
  void customUpdate(){
    environment.update();
  }

  @override
  void customOnPlayerRevived(IsometricPlayer player) {
     if (isSafeToRevive(25, 25)) {
       IsometricGame.setGridPosition(position: player, z: 1, row: 25, column: 25);
       player.characterState = CharacterState.Idle;
       player.writePlayerMoved();
       return;
     }

     for (var row = 0; row < scene.rows; row++) {
        for (var column = 0; column < scene.columns; column++){
          if (isSafeToRevive(row, column)){
            IsometricGame.setGridPosition(position: player, z: 1, row: row, column: column);
            player.writePlayerMoved();
            return;
          }
        }
     }
  }

  bool isSafeToRevive(int row, int column) {
     for (var z = scene.height - 1; z >= 0; z--){
       final type = scene.getType(z, row, column);
        if (type == NodeType.Water) return false;
        if (type == NodeType.Water_Flowing) return false;
     }
     return true;
  }

  @override
  int get maxPlayers => 1;
}