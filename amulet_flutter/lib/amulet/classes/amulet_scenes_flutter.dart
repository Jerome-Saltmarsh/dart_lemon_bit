import 'package:amulet_engine/src.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class AmuletScenesFlutter extends AmuletScenes {

  @override
  Future<Scene> readSceneFromFile(String sceneName) async {
    final fileName = 'assets/scenes/$sceneName.scene';
    final bytes = await loadAssetBytes(fileName);
    return SceneReader.readScene(bytes)..name = sceneName;
  }

  @override
  void saveSceneToFile(Scene scene) {
    // TODO: implement saveSceneToFile
    if (kIsWeb){
      return;
    }

    scene.clearCompiled();
    final sceneWriter = SceneWriter();
    writeBytesToFile(
      fileName: '${scene.name}.scene',
      directory: 'assets/scenes/',
      contents: sceneWriter.compileScene(scene, gameObjects: true),
    );
  }

  Future<File> writeBytesToFile({
    required String fileName,
    required String directory,
    required List<int> contents
  }) async {
    final dir = Directory(directory);
    final exists = await dir.exists();
    if (!exists){
      dir.create();
    }
    final file = File('${dir.path}/$fileName');
    return file.writeAsBytes(contents);
  }
}