

import 'dart:io';

import '../packages/amulet_engine/src.dart';

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
