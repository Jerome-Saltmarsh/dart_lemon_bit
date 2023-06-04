
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene.dart';
import 'package:bleed_server/src/games/isometric/isometric_scene_writer.dart';

import 'save_directory.dart';


void writeSceneToFileBytes(IsometricScene scene) {
  writeBytesToFile(
    fileName: '${scene.name}.scene',
    directory: Scene_Directory_Path,
    contents: IsometricSceneWriter.compileScene(scene, gameObjects: true),
  );
}