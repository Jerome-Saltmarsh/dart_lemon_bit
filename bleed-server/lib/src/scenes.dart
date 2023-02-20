import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/io/write_scene_to_file.dart';

import 'io/load_scene.dart';

class Scenes {
  late Scene suburbs_01;
  late Scene warehouse;

  List<Scene> values = [];

  Future load() async {
      suburbs_01 = await loadScene('suburbs_01');
      warehouse = await loadScene('warehouse');
  }

  void saveAllToFile(){
    values.forEach(writeSceneToFileBytes);
  }
}
