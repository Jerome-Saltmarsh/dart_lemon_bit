
import '../classes/Scene.dart';
import 'constant_save_directory.dart';
import 'convert_scene_to_json.dart';
import 'write_string_to_file.dart';

void writeSceneToFile(Scene scene) {
  writeStringToFile(
    fileName: 'castle.json',
    directory: saveDirectory,
    contents: convertSceneToJson(scene),
  );
}