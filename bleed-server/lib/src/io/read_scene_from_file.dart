
import 'dart:convert';
import 'dart:io';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/scene_writer.dart';
import 'save_directory.dart';
import 'convert_json_to_scene.dart';

Future<Scene> readSceneFromFileJson(String sceneName) async {
  final file = File('$Scene_Directory_Path/$sceneName.json');
  final text = await file.readAsString();
  final json = jsonDecode(text);
  return convertJsonToScene(json, sceneName);
}

Future<Scene> readSceneFromFileBytes(String sceneName) async {
  final fileName = '$Scene_Directory_Path/$sceneName.scene';
  final file = File(fileName);
  final exists = await file.exists();
  if (!exists) {
    throw Exception('could not find scene: $fileName');
  }
  final bytes = await file.readAsBytes();
  return SceneReader.readScene(bytes)..name = sceneName;
}