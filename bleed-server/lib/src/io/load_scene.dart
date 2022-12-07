import 'package:bleed_server/gamestream.dart';
import 'read_scene_from_file.dart';

Future<Scene> loadScene(String sceneName) async {
   // return readSceneFromFileJson(sceneName);
   return readSceneFromFileBytes(sceneName);
}