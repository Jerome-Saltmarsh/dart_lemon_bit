import '../packages/isometric_engine/isometric_engine.dart';

abstract class AmuletScenes {

  late Scene world_00;
  late Scene world_11;
  late Scene witchesLair;
  late Scene tutorial;

  Future load() async {
    world_00 = await readSceneFromFile('world_00');
    world_11 = await readSceneFromFile('world_11');
    tutorial = await readSceneFromFile('tutorial');
    witchesLair = await readSceneFromFile('witches_lair');
  }

  Future<Scene> readSceneFromFile(String sceneName);

  void saveSceneToFile(Scene scene);
}
