import 'dart:typed_data';

import 'package:bleed_server/common/src/character_state.dart';
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/node_orientation.dart';
import 'package:bleed_server/common/src/node_type.dart';
import 'isometric/isometric_environment.dart';
import 'isometric/isometric_game.dart';
import 'isometric/isometric_player.dart';
import 'isometric/isometric_scene.dart';
import 'isometric/isometric_time.dart';

class GameEditor extends IsometricGame {

  GameEditor({IsometricScene? scene}) : super(
      scene: scene ?? generateEmptyScene(),
      environment: IsometricEnvironment(),
      time: IsometricTime(),
      gameType: GameType.Editor,
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

  static IsometricScene generateEmptyScene({int height = 8, int rows = 50, int columns = 50}){
    final area = rows * columns;
    final total = height * area;
    final nodeTypes = Uint8List(total);
    final nodeOrientations = Uint8List(total);

    for (var i = 0; i < area; i++){
      nodeTypes[i] = NodeType.Grass;
      nodeOrientations[i] = NodeOrientation.Solid;
    }

    return IsometricScene(
      name: '',
      gameObjects: [],
      gridHeight: height,
      gridColumns: columns,
      gridRows: rows,
      nodeTypes: nodeTypes,
      nodeOrientations: nodeOrientations,
      spawnPoints: Uint16List(0),
      spawnPointTypes: Uint16List(0),
      spawnPointsPlayers:Uint16List(0),
    );
  }
}