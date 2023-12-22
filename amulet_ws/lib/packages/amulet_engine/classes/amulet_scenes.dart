import '../packages/isometric_engine/isometric_engine.dart';

abstract class AmuletScenes {

  late Scene world_00;
  late Scene world_11;
  late Scene witchesLair1;
  late Scene witchesLair2;
  late Scene tutorial;

  Future load() async {
    world_00 = await readSceneFromFile('world_00');
    world_11 = await readSceneFromFile('world_11');
    tutorial = await readSceneFromFile('tutorial');
    witchesLair1 = await readSceneFromFile('witches_lair_1');
    witchesLair2 = await readSceneFromFile('witches_lair_2');
  }

  Future<Scene> readSceneFromFile(String sceneName);

  void saveSceneToFile(Scene scene);
}
