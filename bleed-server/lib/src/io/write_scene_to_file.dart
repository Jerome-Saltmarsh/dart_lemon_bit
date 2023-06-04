
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/scene_writer.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene.dart';

import 'save_directory.dart';


void writeSceneToFileBytes(IsometricScene scene) {
  writeBytesToFile(
    fileName: '${scene.name}.scene',
    directory: Scene_Directory_Path,
    contents: SceneWriter.compileScene(scene, gameObjects: true),
  );
}