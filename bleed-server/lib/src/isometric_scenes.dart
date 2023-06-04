import 'dart:io';

import '../lemon_io/src/filename_remove_extension.dart';
import '../lemon_io/src/get_file_system_entity_filename.dart';
import 'games/isometric/isometric_scene.dart';
import 'games/isometric/isometric_scene_writer.dart';
import 'system.dart';

class IsometricScenes {
  String get Scene_Directory_Path =>  isLocalMachine ? '${Directory.current.path}/scenes' : '/app/bin/scenes';
  late final Scene_Directory = Directory(Scene_Directory_Path);

  late IsometricScene suburbs_01;
  late IsometricScene warehouse;
  late IsometricScene warehouse02;
  late IsometricScene town;

  Future load() async {
      suburbs_01 = await loadScene('suburbs_01');
      warehouse = await loadScene('warehouse');
      warehouse02 = await loadScene('warehouse02');
      town = await loadScene('town');
  }

  Future<IsometricScene> loadScene(String sceneName) async {
    return readSceneFromFileBytes(sceneName);
  }

  Future<IsometricScene> readSceneFromFileBytes(String sceneName) async {
    final fileName = '$Scene_Directory_Path/$sceneName.scene';
    final file = File(fileName);
    final exists = await file.exists();
    if (!exists) {
      throw Exception('could not find scene: $fileName');
    }
    final bytes = await file.readAsBytes();
    return SceneReader.readScene(bytes)..name = sceneName;
  }

  Future<List<FileSystemEntity>> get saveDirectoryFileSystemEntities =>
      Scene_Directory.list().toList();

  Future<List<String>> getSaveDirectoryFileNames() async {
    final files = await saveDirectoryFileSystemEntities;
    return files
        .map(getFileSystemEntityFileName)
        .map(fileNameRemoveExtension)
        .toList();
  }
}
