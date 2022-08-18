
import '../classes/scene.dart';
import '../lemon_io/write_string_to_file.dart';
import 'save_directory.dart';
import 'convert_scene_to_json.dart';


void writeSceneToFile(Scene scene) {
  writeStringToFile(
    fileName: '${scene.name}.json',
    directory: saveDirectoryPath,
    contents: convertSceneToString(scene),
  );
}