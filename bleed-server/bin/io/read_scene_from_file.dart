
import 'dart:convert';
import 'dart:io';

import '../classes/library.dart';
import 'save_directory.dart';
import 'convert_json_to_scene.dart';

Future<Scene> readSceneFromFile(String sceneName) async {
  final file = File('$saveDirectoryPath/$sceneName.json');
  final text = await file.readAsString();
  final json = jsonDecode(text);
  return convertJsonToScene(json, sceneName);
}