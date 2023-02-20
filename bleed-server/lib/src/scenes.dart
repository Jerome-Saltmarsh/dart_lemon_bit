import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/io/write_scene_to_file.dart';

import 'io/load_scene.dart';

class Scenes {
  late Scene suburbs_01;

  List<Scene> values = [];

  Future load() async {
      print('Loading dark age scenes');
      suburbs_01 = await loadScene('suburbs_01');
      print("Loading dark age scenes finished");
  }

  void saveAllToFile(){
    values.forEach(writeSceneToFileBytes);
  }
}
