import 'package:amulet_engine/isometric/src.dart';
import 'package:amulet_engine/src.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lemon_io/src.dart';

class AmuletScenesFlutter extends AmuletScenes {

  @override
  Future<Scene> readSceneFromFile(String sceneName) async {
    final fileName = 'assets/scenes/$sceneName.scene';
    final bytes = await loadAssetBytes(fileName);
    return SceneReader.readScene(bytes)..name = sceneName;
  }

  @override
  void saveSceneToFile(Scene scene) {
    if (kIsWeb){
      return;
    }

    final sceneWriter = SceneWriter();
    writeBytesToFile(
      fileName: '${scene.name}.scene',
      directory: 'assets/scenes/',
      contents: sceneWriter.compileScene(scene, gameObjects: true),
    );

    // final sceneJson = writeSceneToJson(scene);
  }
}