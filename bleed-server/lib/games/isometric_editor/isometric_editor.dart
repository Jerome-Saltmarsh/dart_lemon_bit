import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';

class IsometricEditor extends IsometricGame {

  IsometricEditor({IsometricScene? scene}) : super(
      scene: scene ?? IsometricSceneGenerator.generateEmptyScene(),
      environment: IsometricEnvironment(),
      time: IsometricTime(),
      gameType: GameType.Editor,
  );

  @override
  void customUpdate(){
    environment.update();
  }

  @override
  void customOnPlayerRevived(IsometricPlayer player) {
     if (isSafeToRevive(25, 25)) {
       IsometricGame.setGridPosition(position: player, z: 1, row: 25, column: 25);
       player.state = CharacterState.Idle;
       player.writePlayerMoved();
       return;
     }

     for (var row = 0; row < scene.gridRows; row++) {
        for (var column = 0; column < scene.gridColumns; column++){
          if (isSafeToRevive(row, column)){
            IsometricGame.setGridPosition(position: player, z: 1, row: row, column: column);
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

  @override
  IsometricPlayer buildPlayer() {
    return IsometricPlayer(game: this);
  }

  @override
  int get maxPlayers => 1;
}