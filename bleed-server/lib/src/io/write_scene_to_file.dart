
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/classes/src/scene_writer.dart';
import 'save_directory.dart';
import 'convert_scene_to_json.dart';


void writeSceneToFileJson(Scene scene) {
  writeStringToFile(
    fileName: '${scene.name}.json',
    directory: saveDirectoryPath,
    contents: convertSceneToString(scene),
  );
}

void writeSceneToFileBytes(Scene scene) {
  writeBytesToFile(
    fileName: '${scene.name}.scene',
    directory: saveDirectoryPath,
    contents: SceneWriter.compileScene(scene, gameObjects: true),
  );
}