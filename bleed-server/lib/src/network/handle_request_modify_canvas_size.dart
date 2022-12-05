import 'package:bleed_server/gamestream.dart';
import 'dart:typed_data';


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
        character.x += Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x += Node_Size;
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
        character.x -= Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x -= Node_Size;
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
        character.x += Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x += Node_Size;
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
        character.x -= Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x -= Node_Size;
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
      final newGridVolume = scene.gridVolume + (scene.gridRows * scene.gridHeight);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var iNew = 0;
      for (var iOld = 0; iOld < scene.gridVolume; iOld++) {
        if (iOld % scene.gridColumns == 0){
          var type = iOld < scene.gridArea ? NodeType.Grass : NodeType.Empty;
          var orientation = NodeType.getDefaultOrientation(type);
          newNodeTypes[iNew] = type;
          newNodeOrientations[iNew] = orientation;
          iNew++;
        }
        newNodeTypes[iNew] = scene.nodeTypes[iOld];
        newNodeOrientations[iNew] = scene.nodeOrientations[iOld];
        iNew++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridColumns++;
      game.onGridChanged();
      for (final character in game.characters) {
        character.y += Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.y += Node_Size;
      }
      break;
    case RequestModifyCanvasSize.Remove_Column_Start:
      final newGridVolume = scene.gridVolume - (scene.gridRows * scene.gridHeight);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.gridVolume; i++) {
        if (i % scene.gridColumns == 0) continue;
        newNodeTypes[newIndex] = scene.nodeTypes[i];
        newNodeOrientations[newIndex] = scene.nodeOrientations[i];
        newIndex++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.gridColumns--;
      game.onGridChanged();
      for (final character in game.characters) {
        character.y -= Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.y -= Node_Size;
      }
      break;
    case RequestModifyCanvasSize.Add_Column_End:
    // TODO: Handle this case.
      break;
    case RequestModifyCanvasSize.Remove_Column_End:
    // TODO: Handle this case.
      break;
  }
}