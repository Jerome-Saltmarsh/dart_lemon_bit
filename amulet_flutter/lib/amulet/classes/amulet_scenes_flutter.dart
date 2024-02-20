import 'package:amulet_engine/io/scene_json_reader.dart';
import 'package:amulet_engine/isometric/src.dart';
import 'package:amulet_engine/src.dart';
// import 'package:lemon_engine/lemon_engine.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lemon_io/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
// import 'package:lemon_widgets/lemon_widgets.dart';

class AmuletScenesFlutter extends AmuletScenes {

  @override
  Future<Scene> readSceneFromFile(String sceneName) async {
    // final fileName = 'assets/scenes/$sceneName.scene';
    // final bytes = await loadAssetBytes(fileName);
    // return SceneReader.readScene(bytes)..name = sceneName;
    final sceneJson = await loadAssetJson('assets/scenes/$sceneName.json');
    return readSceneFromJson(sceneJson);
  }

  @override
  void saveSceneToFile(Scene scene) {
    if (kIsWeb){
      return;
    }

    // final sceneWriter = SceneWriter();
    // writeBytesToFile(
    //   fileName: '${scene.name}.scene',
    //   directory: 'assets/scenes/',
    //   contents: sceneWriter.compileScene(scene, gameObjects: true),
    // );

    writeJsonToFile(
        fileName: '${scene.name}.json',
        directory: 'assets/scenes/',
        json: writeSceneToJson(scene),
    );
  }
}