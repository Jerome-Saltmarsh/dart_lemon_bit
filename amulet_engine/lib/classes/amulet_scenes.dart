import '../packages/isometric_engine/isometric_engine.dart';

abstract class AmuletScenes {

  late Scene world_01_01;
  late Scene witchesLair;
  late Scene tutorial;

  Future load() async {
    world_01_01 = await readSceneFromFile('world_01_01');
    tutorial = await readSceneFromFile('tutorial');
    witchesLair = await readSceneFromFile('witches_lair');
  }

  Future<Scene> readSceneFromFile(String sceneName);

  void saveSceneToFile(Scene scene);
}
