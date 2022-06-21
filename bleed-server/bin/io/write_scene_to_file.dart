
import '../classes/Scene.dart';
import '../lemon_io/write_string_to_file.dart';
import 'constant_save_directory.dart';
import 'convert_scene_to_json.dart';


void writeSceneToFile(Scene scene) {
  writeStringToFile(
    fileName: 'castle.json',
    directory: saveDirectory,
    contents: convertSceneToString(scene),
  );
}