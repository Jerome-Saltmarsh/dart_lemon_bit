import 'dart:io';

import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/lemon_io/src/filename_remove_extension.dart';
import 'package:gamestream_server/lemon_io/src/get_file_system_entity_filename.dart';
import 'package:gamestream_server/lemon_io/src/write_string_to_file.dart';
import 'package:gamestream_server/utils/system.dart';

import 'scene_reader.dart';

class Scenes {
  String get sceneDirectoryPath =>  isLocalMachine ? '${Directory.current.path}/scenes' : '/app/bin/scenes';
  late final sceneDirectory = Directory(sceneDirectoryPath);

  late Scene captureTheFlag;
  late Scene moba;
  late Scene mmoTown;

  Future load() async {
      mmoTown = await readSceneFromFile('mmo');
  }

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
    writeBytesToFile(
      fileName: '${scene.name}.scene',
      directory: sceneDirectoryPath,
      contents: SceneWriter.compileScene(scene, gameObjects: true),
    );
  }
}
