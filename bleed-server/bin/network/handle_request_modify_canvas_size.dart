
import 'dart:typed_data';

import '../classes/player.dart';
import '../common/node_size.dart';
import '../common/node_type.dart';
import '../common/request_modify_canvas_size.dart';

void handleRequestModifyCanvasSize(RequestModifyCanvasSize request, Player player){
  final game = player.game;
  final scene = game.scene;
  switch (request) {
    case RequestModifyCanvasSize.Add_Row_Start:
      final newGridVolume = scene.gridVolume + (scene.gridColumns * scene.gridHeight);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.gridVolume; i++) {
        if (i % scene.gridArea == 0){
          final k = newIndex;
          var type = i < scene.gridArea ? NodeType.Grass : NodeType.Empty;
          var orientation = NodeType.getDefaultOrientation(type);
          for (var j = 0; j < scene.gridColumns; j++){
            newNodeTypes[k + j] = type;
            newNodeOrientations[k + j] = orientation;
            newIndex++;
          }
        }
        newNodeTypes[newIndex] = scene.nodeTypes[i];
        newNodeOrientations[newIndex] = scene.nodeOrientations[i];
        newIndex++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridRows++;
      game.onGridChanged();

      for (final character in game.characters) {
        character.x += nodeSize;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x += nodeSize;
      }
      break;
    case RequestModifyCanvasSize.Remove_Row_Start:
      final newGridVolume = scene.gridVolume - (scene.gridColumns * scene.gridHeight);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.gridVolume; i++) {
        if (i % scene.gridArea == 0){
          i += scene.gridColumns;
        }
        newNodeTypes[newIndex] = scene.nodeTypes[i];
        newNodeOrientations[newIndex] = scene.nodeOrientations[i];
        newIndex++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridRows--;
      game.onGridChanged();
      for (final character in game.characters) {
        character.x -= nodeSize;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x -= nodeSize;
      }
      break;
    case RequestModifyCanvasSize.Add_Row_End:
      final newGridVolume = scene.gridVolume + (scene.gridColumns * scene.gridHeight);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.gridVolume; i++) {
        if (i % scene.gridArea == scene.gridArea - scene.gridColumns){
          final k = newIndex;
          var type = i < scene.gridArea ? NodeType.Grass : NodeType.Empty;
          var orientation = NodeType.getDefaultOrientation(type);
          for (var j = 0; j < scene.gridColumns; j++){
            newNodeTypes[k + j] = type;
            newNodeOrientations[k + j] = orientation;
            newIndex++;
          }
        }
        newNodeTypes[newIndex] = scene.nodeTypes[i];
        newNodeOrientations[newIndex] = scene.nodeOrientations[i];
        newIndex++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridRows++;
      game.onGridChanged();

      for (final character in game.characters) {
        character.x += nodeSize;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x += nodeSize;
      }
      break;
    case RequestModifyCanvasSize.Remove_Row_End:
      final newGridVolume = scene.gridVolume - (scene.gridColumns * scene.gridHeight);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.gridVolume; i++) {
        if (i % scene.gridArea == scene.gridArea - scene.gridColumns){
          i += scene.gridColumns;
        }
        if (i < scene.gridVolume){
          newNodeTypes[newIndex] = scene.nodeTypes[i];
          newNodeOrientations[newIndex] = scene.nodeOrientations[i];
          newIndex++;
        }
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridRows--;
      game.onGridChanged();
      for (final character in game.characters) {
        character.x -= nodeSize;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x -= nodeSize;
      }
      break;
    case RequestModifyCanvasSize.Add_Z:
      final newGridVolume = scene.gridVolume + (scene.gridArea);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      for (var i = 0; i < scene.gridVolume; i++){
        newNodeTypes[i] = scene.nodeTypes[i];
        newNodeOrientations[i] = scene.nodeOrientations[i];
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridHeight++;
      game.onGridChanged();
      break;
    case RequestModifyCanvasSize.Remove_Z:
      if (scene.gridHeight <= 5) return;
      final newGridVolume = scene.gridVolume - (scene.gridArea);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      for (var i = 0; i < newGridVolume; i++){
        newNodeTypes[i] = scene.nodeTypes[i];
        newNodeOrientations[i] = scene.nodeOrientations[i];
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridHeight--;
      game.onGridChanged();
      break;
    case RequestModifyCanvasSize.Add_Column_Start:
    // TODO: Handle this case.
      break;
    case RequestModifyCanvasSize.Remove_Column_Start:
    // TODO: Handle this case.
      break;
    case RequestModifyCanvasSize.Add_Column_End:
    // TODO: Handle this case.
      break;
    case RequestModifyCanvasSize.Remove_Column_End:
    // TODO: Handle this case.
      break;
  }
}