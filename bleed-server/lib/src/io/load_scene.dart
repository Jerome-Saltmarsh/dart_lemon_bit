import 'package:bleed_server/src/games/isometric/isometric_scene.dart';
import 'read_scene_from_file.dart';

Future<IsometricScene> loadScene(String sceneName) async {
   return readSceneFromFileBytes(sceneName);
}