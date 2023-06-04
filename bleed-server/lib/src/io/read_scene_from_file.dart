
import 'dart:io';
import 'package:bleed_server/src/classes/src/scene_writer.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene.dart';
import 'save_directory.dart';

Future<IsometricScene> readSceneFromFileBytes(String sceneName) async {
  final fileName = '$Scene_Directory_Path/$sceneName.scene';
  final file = File(fileName);
  final exists = await file.exists();
  if (!exists) {
    throw Exception('could not find scene: $fileName');
  }
  final bytes = await file.readAsBytes();
  return SceneReader.readScene(bytes)..name = sceneName;
}