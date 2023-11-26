import '../packages/isometric_engine/isometric_engine.dart';

abstract class AmuletScenes {

  late Scene moba;
  late Scene mmoTown;
  late Scene road01;
  late Scene road02;
  late Scene tutorial;
  late Scene tutorial02;

  Future load() async {
    mmoTown = await readSceneFromFile('mmo');
    road01 = await readSceneFromFile('road_01');
    road02 = await readSceneFromFile('road_02');
    tutorial = await readSceneFromFile('tutorial');
    tutorial02 = await readSceneFromFile('tutorial_02');
  }

  Future<Scene> readSceneFromFile(String sceneName);

  void saveSceneToFile(Scene scene);
}
