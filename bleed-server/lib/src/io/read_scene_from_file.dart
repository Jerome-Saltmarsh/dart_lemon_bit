
import 'dart:convert';
import 'dart:io';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/scene_writer.dart';
import 'save_directory.dart';
import 'convert_json_to_scene.dart';

Future<Scene> readSceneFromFileJson(String sceneName) async {
  final file = File('$saveDirectoryPath/$sceneName.json');
  final text = await file.readAsString();
  final json = jsonDecode(text);
  return convertJsonToScene(json, sceneName);
}

Future<Scene> readSceneFromFileBytes(String sceneName) async {
  final file = File('$saveDirectoryPath/$sceneName.scene');
  final bytes = await file.readAsBytes();
  return SceneReader.readScene(bytes)..name = sceneName;
}