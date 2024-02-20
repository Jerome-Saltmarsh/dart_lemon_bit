import 'dart:typed_data';

import 'package:amulet_engine/isometric/classes/isometric_player.dart';
import 'package:amulet_engine/common/src.dart';

void handleRequestModifyCanvasSize(NetworkRequestModifyCanvasSize request, IsometricPlayer player){
  final game = player.game;
  final scene = game.scene;
  switch (request) {
    case NetworkRequestModifyCanvasSize.Add_Row_Start:
      final newGridVolume = scene.volume + (scene.columns * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.volume; i++) {
        if (i % scene.area == 0){
          final k = newIndex;
          var type = i < scene.area ? NodeType.Grass : NodeType.Empty;
          var orientation = NodeType.getDefaultOrientation(type);
          for (var j = 0; j < scene.columns; j++){
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
      scene.rows++;
      game.onGridChanged();

      for (final character in game.characters) {
        character.x += Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x += Node_Size;
      }
      break;
    case NetworkRequestModifyCanvasSize.Remove_Row_Start:
      final newGridVolume = scene.volume - (scene.columns * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.volume; i++) {
        if (i % scene.area == 0){
          i += scene.columns;
        }
        newNodeTypes[newIndex] = scene.nodeTypes[i];
        newNodeOrientations[newIndex] = scene.nodeOrientations[i];
        newIndex++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.rows--;
      game.onGridChanged();
      for (final character in game.characters) {
        character.x -= Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x -= Node_Size;
      }
      break;
    case NetworkRequestModifyCanvasSize.Add_Row_End:
      final newGridVolume = scene.volume + (scene.columns * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.volume; i++) {
        if (i % scene.area == scene.area - scene.columns){
          final k = newIndex;
          var type = i < scene.area ? NodeType.Grass : NodeType.Empty;
          var orientation = NodeType.getDefaultOrientation(type);
          for (var j = 0; j < scene.columns; j++){
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
      scene.rows++;
      game.onGridChanged();

      for (final character in game.characters) {
        character.x += Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.x += Node_Size;
      }
      break;
    case NetworkRequestModifyCanvasSize.Remove_Row_End:
      final newGridVolume = scene.volume - (scene.columns * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.volume; i++) {
        if (i % scene.area == scene.area - scene.columns){
          i += scene.columns;
        }
        if (i < scene.volume){
          newNodeTypes[newIndex] = scene.nodeTypes[i];
          newNodeOrientations[newIndex] = scene.nodeOrientations[i];
          newIndex++;
        }
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.rows--;
      game.onGridChanged();
      break;
    case NetworkRequestModifyCanvasSize.Add_Z:
      final newGridVolume = scene.volume + (scene.area);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      for (var i = 0; i < scene.volume; i++){
        newNodeTypes[i] = scene.nodeTypes[i];
        newNodeOrientations[i] = scene.nodeOrientations[i];
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.height++;
      game.onGridChanged();
      break;
    case NetworkRequestModifyCanvasSize.Remove_Z:
      if (scene.height <= 5) return;
      final newGridVolume = scene.volume - (scene.area);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      for (var i = 0; i < newGridVolume; i++){
        newNodeTypes[i] = scene.nodeTypes[i];
        newNodeOrientations[i] = scene.nodeOrientations[i];
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.height--;
      game.onGridChanged();
      break;
    case NetworkRequestModifyCanvasSize.Add_Column_Start:
      final newGridVolume = scene.volume + (scene.rows * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var iNew = 0;
      for (var iOld = 0; iOld < scene.volume; iOld++) {
        if (iOld % scene.columns == 0){
          var type = iOld < scene.area ? NodeType.Grass : NodeType.Empty;
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
      scene.columns++;
      game.onGridChanged();
      for (final character in game.characters) {
        character.y += Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.y += Node_Size;
      }
      break;
    case NetworkRequestModifyCanvasSize.Remove_Column_Start:
      final newGridVolume = scene.volume - (scene.rows * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.volume; i++) {
        if (i % scene.columns == 0) continue;
        newNodeTypes[newIndex] = scene.nodeTypes[i];
        newNodeOrientations[newIndex] = scene.nodeOrientations[i];
        newIndex++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.columns--;
      game.onGridChanged();
      for (final character in game.characters) {
        character.y -= Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.y -= Node_Size;
      }
      break;
    case NetworkRequestModifyCanvasSize.Add_Column_End:
      final newGridVolume = scene.volume + (scene.rows * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var iNew = 0;
      for (var iOld = 0; iOld < scene.volume; iOld++) {
        if (iOld % scene.columns == scene.columns - 1){
          var type = iOld < scene.area ? NodeType.Grass : NodeType.Empty;
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
      scene.columns++;
      game.onGridChanged();
      for (final character in game.characters) {
        character.y += Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.y += Node_Size;
      }
      break;
    case NetworkRequestModifyCanvasSize.Remove_Column_End:
      final newGridVolume = scene.volume - (scene.rows * scene.height);
      final newNodeTypes = Uint8List(newGridVolume);
      final newNodeOrientations = Uint8List(newGridVolume);
      var newIndex = 0;
      for (var i = 0; i < scene.volume; i++) {
        if (i % scene.columns == scene.columns - 1) continue;
        newNodeTypes[newIndex] = scene.nodeTypes[i];
        newNodeOrientations[newIndex] = scene.nodeOrientations[i];
        newIndex++;
      }
      scene.nodeTypes = newNodeTypes;
      scene.nodeOrientations = newNodeOrientations;
      scene.columns--;
      game.onGridChanged();
      for (final character in game.characters) {
        character.y -= Node_Size;
      }
      for (final gameObject in game.gameObjects) {
        gameObject.y -= Node_Size;
      }
      break;
  }
}