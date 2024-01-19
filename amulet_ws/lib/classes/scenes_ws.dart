

import 'dart:io';

import 'package:amulet_ws/packages/amulet_engine/classes/amulet_scenes.dart';
import 'package:amulet_ws/packages/amulet_engine/packages/isometric_engine/classes/scene.dart';
import 'package:amulet_ws/packages/amulet_engine/packages/isometric_engine/classes/scene_reader.dart';
import 'package:amulet_ws/packages/amulet_engine/packages/isometric_engine/classes/scene_writer.dart';
import 'package:amulet_ws/packages/amulet_engine/packages/isometric_engine/packages/lemon_io/src/write_string_to_file.dart';

import '../packages/amulet_engine/packages/isometric_engine/packages/lemon_io/src/filename_remove_extension.dart';
import '../packages/amulet_engine/packages/isometric_engine/packages/lemon_io/src/get_file_system_entity_filename.dart';

class AmuletScenesIO extends AmuletScenes {
  final String sceneDirectoryPath;
  late final sceneDirectory = Directory(sceneDirectoryPath);

  AmuletScenesIO({required this.sceneDirectoryPath});


  Future<Scene> readSceneFromFile(String sceneName) async {
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

  void saveSceneToFile(Scene scene) {
    scene.clearCompiled();
    final sceneWriter = SceneWriter();
    writeBytesToFile(
      fileName: '${scene.name}.scene',
      directory: sceneDirectoryPath,
      contents: sceneWriter.compileScene(scene, gameObjects: true),
    );
  }
}
