import 'dart:io';

import 'package:lemon_atlas/amulet/functions/load_images_from_directory.dart';
import 'package:lemon_atlas/atlas/src.dart';

const dirRenders = 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/renders';
const dirSprites = 'C:/Users/Jerome/github/bleed/gamestream_flutter/sprites';

Future synchronize() => listFilesRecursively(Directory(dirRenders));

Future listFilesRecursively(Directory directory) async {
  return directory.listSync().forEach((child) async {
    if (child is File) {
      await ensureSynchronized(child);
      return;
    }

    if (child is Directory) {
      return listFilesRecursively(child);
    }
  });
}

Future ensureSynchronized(File file) async {

  final lastModified = await file.lastModified();
  final nameAbsolute = file.path.replaceAll(dirRenders, '');
  final name = removeLastDirectory(nameAbsolute);
  final fileName = getLastFolder(name);
  final targetDirectory = removeLastDirectory('$dirSprites/$name');
  final filePath = '$targetDirectory/$fileName';
  final fileJson = File('$filePath.json');
  final filePng = File('$filePath.png');
  final srcDir = file.parent.path;


  if (
    !fileJson.existsSync() ||
    !filePng.existsSync() ||
    (await fileJson.lastModified()).isBefore(lastModified) ||
    (await filePng.lastModified()).isBefore(lastModified)
  ){
    await sync(
      srcDir: clean(srcDir),
      targetDirectory: clean(targetDirectory),
      name: fileName,
    );
  }
}

String clean(String directory){
  return directory.replaceAll('\\', '/').replaceAll("//", '/');
}

String removeLastDirectory(String path) {
  final parts = path.split(Platform.pathSeparator);
  if (parts.isNotEmpty) {
    parts.removeLast();
  }
  return parts.join(Platform.pathSeparator);
}


String getLastFolder(String path) {
  final parts = path.split(Platform.pathSeparator);
  if (parts.isNotEmpty) {
    return parts.last;
  }
  return '';
}

String getParentName(File file) {
  final segments = file.parent.uri.pathSegments;
  if (segments.length <= 2){
    return '';
  }
  return segments[segments.length - 2];
}

Future sync({
  required String srcDir,
  required String targetDirectory,
  required String name,
}) async {
  final srcImages = await loadImagesFomDirectory(srcDir);

  if (srcImages.length % 8 != 0){
    return;
  }

  final sprite = buildSpriteFromSrcImages(
    srcImages: srcImages,
    rows: 8,
    columns: srcImages.length ~/ 8,
  );

  if (sprite.image.isEmpty){
    throw Exception('sprite is empty');
  }

  print('sync(src: "$srcDir", target: "$targetDirectory", name: "$name")');
  exportSprite(
    sprite: sprite,
    directory: targetDirectory,
    name: name,
  );
  print('done');
}