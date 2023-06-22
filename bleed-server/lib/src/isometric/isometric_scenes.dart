import 'dart:io';

import 'package:bleed_server/lemon_io/src/filename_remove_extension.dart';
import 'package:bleed_server/lemon_io/src/get_file_system_entity_filename.dart';
import 'package:bleed_server/lemon_io/src/write_string_to_file.dart';
import 'package:bleed_server/src/utilities/system.dart';

import 'isometric_scene.dart';
import 'isometric_scene_writer.dart';

class IsometricScenes {
  String get sceneDirectoryPath =>  isLocalMachine ? '${Directory.current.path}/scenes' : '/app/bin/scenes';
  late final sceneDirectory = Directory(sceneDirectoryPath);

  late IsometricScene suburbs_01;
  late IsometricScene warehouse;
  late IsometricScene warehouse02;
  late IsometricScene town;
  late IsometricScene captureTheFlag;

  Future load() async {
      suburbs_01 = await loadScene('suburbs_01');
      warehouse = await loadScene('warehouse');
      warehouse02 = await loadScene('warehouse02');
      town = await loadScene('town');
      captureTheFlag = await loadScene('capture_the_flag');
  }

  Future<IsometricScene> loadScene(String sceneName) async {
    return readSceneFromFileBytes(sceneName);
  }

  Future<IsometricScene> readSceneFromFileBytes(String sceneName) async {
    final fileName = '$sceneDirectoryPath/$sceneName.scene';
    final file = File(fileName);
    final exists = await file.exists();
    if (!exists) {
      throw Exception('could not find scene: $fileName');
    }
    final bytes = await file.readAsBytes();
    return SceneReader.readScene(bytes)..name = sceneName;
  }

  Future<List<FileSystemEntity>> get saveDirectoryFileSystemEntities =>
      sceneDirectory.list().toList();

  Future<List<String>> getSaveDirectoryFileNames() async {
    final files = await saveDirectoryFileSystemEntities;
    return files
        .map(getFileSystemEntityFileName)
        .map(fileNameRemoveExtension)
        .toList();
  }

  void saveSceneToFileBytes(IsometricScene scene) {
    writeBytesToFile(
      fileName: '${scene.name}.scene',
      directory: sceneDirectoryPath,
      contents: IsometricSceneWriter.compileScene(scene, gameObjects: true),
    );
  }
}
