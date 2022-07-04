
import '../classes/library.dart';
import 'read_scene_from_file.dart';

Future<Scene> loadScene(String sceneName) async {
   return readSceneFromFile(sceneName);
}