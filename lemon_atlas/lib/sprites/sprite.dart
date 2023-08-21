
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_atlas/sprites/copy_paste.dart';
import 'package:lemon_atlas/sprites/kid_part.dart';
import 'package:lemon_atlas/sprites/kid_state.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../functions/find_bounds.dart';

class ImagePack {
  final Image image;
  final int spriteWidth;
  final int spriteHeight;
  final int rows;
  final int columns;
  final Uint16List bounds;

  ImagePack({
    required this.image,
    required this.spriteWidth,
    required this.spriteHeight,
    required this.rows,
    required this.columns,
    required this.bounds,
  });
}

class Sprite {

  final transparent = ColorRgba8(0, 0, 0, 0);

  void buildKidStateAndPart({
    required KidState state,
    required KidPart part,
    required int rows,
    required int columns,
  }) async {

    final renders = await getImages(state, part);
    final bounds = buildBounds(renders, rows, columns);

    final width = getTotalWidthFromBounds(bounds);
    final height = getMaxHeightFromBounds(bounds);

    final packedImage = Image(width: width, height: height, numChannels: 4, backgroundColor: transparent);
    final dst = buildDstFromBounds(bounds);

    var i = 0;

    var dstX = 0;
    var dstY = 0;

    for (final render in renders){
      final left = bounds[i++];
      final top = bounds[i++];
      final right = bounds[i++];
      final bottom = bounds[i++];

      final renderWidth = right - left;
      final renderHeight = bottom - top;

      copyPaste(
          srcImage: render,
          dstImage: packedImage,
          width: renderWidth,
          height: renderHeight,
          srcX: left,
          srcY: top,
          dstX: dstX,
          dstY: dstY,
      );
      dstX += renderWidth;
    }

    final groupName = KidPart.getGroupName(part);
    final packedBytes = encodePng(packedImage);
    final outputName = state.name;
    final directory = 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/sprites/kid/$groupName/${part.fileName}';
    await createDirectoryIfNotExists(directory);
    final png = File('$directory/$outputName.png');
    await png.writeAsBytes(packedBytes);
    final dstFile = File('$directory/$outputName.dst');
    await dstFile.writeAsBytes(dst.buffer.asUint8List());
  }

  Uint16List buildDstFromBounds(Uint16List bounds){
    final dst = Uint16List(bounds.length ~/ 4 * 6);

    var i = 0;

    var dstX = 0;
    var dstY = 0;

    while (i < bounds.length){
      final left = bounds[i++];
      final top = bounds[i++];
      final right = bounds[i++];
      final bottom = bounds[i++];
      final width = right - left;
      final height = bottom - top;

      dst[i++] = dstX;
      dst[i++] = dstY;
      dst[i++] = width;
      dst[i++] = height;
      dst[i++] = left;
      dst[i++] = top;
    }

    return dst;
  }

  int getTotalWidthFromBounds(Uint16List bounds){
     var totalWidth = 0;
     var i = 0;
     while (i < bounds.length){
        final left = bounds[i];
        final right = bounds[i + 2];
        totalWidth += (right - left);
        i += 4;
     }
     return totalWidth;
  }

  int getMaxHeightFromBounds(Uint16List bounds){
    var maxHeight = 0;
    var i = 0;
    while (i < bounds.length){
      final top = bounds[i + 1];
      final bottom = bounds[i + 3];
      final height = bottom - top;
      maxHeight = max(maxHeight, height);
      i += 4;
    }
    return maxHeight;
  }

  Uint16List buildBounds(List<Image> images, int rows, int columns){
    final bounds = Uint16List(rows * columns * 4);
    var i = 0;

    for (final image in images){
      bounds[i++] = findBoundsLeft(image);
      bounds[i++] = findBoundsTop(image);
      bounds[i++] = findBoundsRight(image);
      bounds[i++] = findBoundsBottom(image);
    }
    return bounds;
  }

  Future<List<Image>> getImages(KidState state, KidPart part) async {
    final directoryName = getDirectoryName(state, part);
    final images = <Image> [];
    final now = DateTime.now();
    for (var i = 1; i <= 64; i++){
      final iPadded = i.toString().padLeft(4, '0');
      final fileName = '$directoryName/$iPadded.png';
      final bytes = await loadAssetBytes(fileName);
      final image = decodePng(bytes);

      if (image == null) {
        throw Exception();
      }

      images.add(image);
    }
    return images;
  }

  String getDirectoryName(KidState state, KidPart part) =>
      'assets/renders/kid/${KidPart.getGroupName(part)}/${part.fileName}/${state.name}';

  Future createDirectoryIfNotExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      return;
    }
    await directory.create(recursive: true);
  }
}


