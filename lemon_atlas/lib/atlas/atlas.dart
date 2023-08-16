
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class Atlas {
  final files = <PlatformFile>[];
  final images = <Image>[];
  
  Future addFile() async {
    final files = await loadFilesFromDisk();

    if (files == null){
      return;
    }

    files.clear();
    files.addAll(files);
    processFiles();
  }

  void processFiles() {
    for (final file in files) {
      final bytes = file.bytes;
      if (bytes == null){
        throw Exception('${file.name} bytes == null');
      }

      final image = decodePng(bytes) ?? (throw Exception('could not convert to ${file.name} to image'));
      images.add(image);
    }
    compileAtlas();
  }

  void compileAtlas(){
    var width = 0;
    var height = 0;
    final yPositions = <String, int> {};

    for (final image in images) {
      width = max(width, image.width);
      height += image.height;
    }

    height += images.length;
    final atlas = Image(
        width: width,
        height: height,
        backgroundColor: ColorRgba8(0, 0, 0, 0),
        numChannels: 4,
    );
    var imageY = 0;

    for (var i = 0; i < files.length; i++) {
      yPositions[files[i].name] = imageY;
      final image = images[i];

      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          atlas.setPixel(x, y + imageY, image.getPixel(x, y));
        }
        imageY++;
      }
    }

    downloadBytes(bytes: encodePng(atlas), name: 'test.png');

    // downloadBytes(
    //   bytes: atlas.buffer.asUint8List(),
    //   name: fileName.replaceAll('.png', '.atlas'),
    // );
  }
}

class NamedImage {
  final String name;
  final Image image;
  NamedImage({required this.name, required this.image});
}