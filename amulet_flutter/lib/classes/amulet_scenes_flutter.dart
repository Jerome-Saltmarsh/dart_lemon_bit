import 'package:amulet_engine/src.dart';
import 'package:lemon_engine/lemon_engine.dart';

class AmuletScenesFlutter extends AmuletScenes {

  @override
  Future<Scene> readSceneFromFile(String sceneName) async {
    final fileName = 'scenes/$sceneName.scene';
    final bytes = await loadAssetBytes(fileName);
    return SceneReader.readScene(bytes)..name = sceneName;
  }

  @override
  void saveSceneToFile(Scene scene) {
    // TODO: implement saveSceneToFile
  }
}