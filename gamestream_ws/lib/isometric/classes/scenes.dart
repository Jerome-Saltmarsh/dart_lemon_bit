import 'dart:io';

import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages.dart';


class Scenes {
  String get sceneDirectoryPath =>  isLocalMachine ? '${Directory.current.path}/scenes' : '/app/bin/scenes';
  late final sceneDirectory = Directory(sceneDirectoryPath);

  late Scene captureTheFlag;
  late Scene moba;
  late Scene mmoTown;
  late Scene road01;
  late Scene road02;
  late Scene tutorial;
  late Scene tutorial02;

  Future load() async {
      mmoTown = await readSceneFromFile('mmo');
      road01 = await readSceneFromFile('road_01');
      road02 = await readSceneFromFile('road_02');
      tutorial = await readSceneFromFile('tutorial');
      tutorial02 = await readSceneFromFile('tutorial_02');
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
    scene.clearCompiled();
    writeBytesToFile(
      fileName: '${scene.name}.scene',
      directory: sceneDirectoryPath,
      contents: SceneWriter.compileScene(scene, gameObjects: true),
    );
  }
}
