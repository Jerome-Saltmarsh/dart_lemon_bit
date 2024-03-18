import 'package:amulet_server/io/scene_json_reader.dart';
import 'package:amulet_server/isometric/src.dart';
import 'package:amulet_server/src.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lemon_io/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class AmuletScenesFlutter extends AmuletScenes {

  @override
  Future<Scene> readSceneFromFile(String sceneName) async {
    final sceneJson = await loadAssetJson('assets/scenes/$sceneName.json');
    return readSceneFromJson(sceneJson);
  }

  @override
  void saveSceneToFile(Scene scene) {
    if (kIsWeb){
      return;
    }

    writeJsonToFile(
        fileName: '${scene.name}.json',
        directory: 'assets/scenes/',
        json: writeSceneToJson(scene),
    );
  }
}