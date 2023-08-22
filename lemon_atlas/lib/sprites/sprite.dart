
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_atlas/sprites/copy_paste.dart';
import 'package:lemon_atlas/enums/kid_part.dart';
import 'package:lemon_atlas/enums/character_state.dart';

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
    required character_state state,
    required KidPart part,
    required int rows,
    required int columns,
  }) async {

    final renders = await getImages(state, part);
    final src = buildSrc(renders, rows, columns);
    final dst = buildDstFromSrc(src);
    final width = getTotalWidthFromDst(dst);
    final height = getMaxHeightFromDst(dst);

    final dstImage = Image(
        width: width,
        height: height,
        numChannels: 4,
        backgroundColor: transparent,
        format: Format.uint16,
    );

    var iSrc = 0;
    var iDst = 0;

    for (final srcImage in renders){
      final dstX = dst[iDst + 0];
      final dstY = dst[iDst + 1];

      iDst += 6;

      final left = src[iSrc++];
      final top = src[iSrc++];
      final right = src[iSrc++];
      final bottom = src[iSrc++];

      final renderWidth = right - left;
      final renderHeight = bottom - top;

      copyPaste(
          srcImage: srcImage,
          dstImage: dstImage,
          width: renderWidth,
          height: renderHeight,
          srcX: left,
          srcY: top,
          dstX: dstX,
          dstY: dstY,
      );
    }

    final groupName = part.groupName;
    final dstImageBytes = encodePng(dstImage);
    final outputName = state.name;
    final directory = 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/sprites_2/kid/$groupName/${part.fileName}';
    await createDirectoryIfNotExists(directory);
    final filePng = File('$directory/$outputName.png');
    await filePng.writeAsBytes(dstImageBytes);
    final fileDst = File('$directory/$outputName.dst');
    await fileDst.writeAsBytes(dst.buffer.asUint8List());
    print('saved "$directory/$outputName"');
  }

  Uint16List buildDstFromSrc(Uint16List src){
    final dst = Uint16List(src.length ~/ 4 * 6);

    var iSrc = 0;
    var iDst = 0;

    var dstX = 0;
    var dstY = 0;
    var maxHeight = 0;

    while (iSrc < src.length){
      final left = src[iSrc++];
      final top = src[iSrc++];
      final right = src[iSrc++];
      final bottom = src[iSrc++];
      final width = right - left;
      final height = bottom - top;
      maxHeight = max(maxHeight, height);

      if (dstX + width >= 2048) {
        dstX = 0;
        dstY += maxHeight + 1;
        maxHeight = 0;
      }

      dst[iDst++] = dstX; // left
      dst[iDst++] = dstY; // top
      dst[iDst++] = dstX + width; // right
      dst[iDst++] = dstY + height; // bottom
      dst[iDst++] = left; // dstX
      dst[iDst++] = top;  // dstY

      dstX += width + 1;
    }

    return dst;
  }

  int getTotalWidthFromDst(Uint16List dst){
     var i = 0;
     var maxWidth = 0;
     while (i < dst.length){
        final left = dst[i++];
        final top = dst[i++];
        final right = dst[i++];
        final bottom = dst[i++];
        final dstX = dst[i++];
        final dstY = dst[i++];
        maxWidth = max(maxWidth, right);
     }
     return maxWidth;
  }

  int getMaxHeightFromDst(Uint16List dst){
    var i = 0;
    var maxHeight = 0;
    while (i < dst.length){
      final left = dst[i++];
      final top = dst[i++];
      final right = dst[i++];
      final bottom = dst[i++];
      final dstX = dst[i++];
      final dstY = dst[i++];

      maxHeight = max(maxHeight, bottom);
    }
    return maxHeight;
  }

  Uint16List buildSrc(List<Image> images, int rows, int columns){
    final src = Uint16List(rows * columns * 4);
    var i = 0;

    for (final image in images){
      src[i++] = findBoundsLeft(image);
      src[i++] = findBoundsTop(image);
      src[i++] = findBoundsRight(image);
      src[i++] = findBoundsBottom(image);
    }
    return src;
  }

  Future<List<Image>> getImages(character_state state, KidPart part) async {
    final directoryName = getDirectoryName(state, part);
    final images = <Image> [];
    for (var i = 1; i <= 64; i++){
      final iPadded = i.toString().padLeft(4, '0');
      final fileName = '$directoryName/$iPadded.png';
      final bytes = await loadFileBytes(fileName);
      final image = decodePng(bytes);

      if (image == null) {
        throw Exception();
      }
      images.add(image);
    }
    return images;
  }

  String getDirectoryName(character_state state, KidPart part) =>
      'assets/renders/kid/${part.groupName}/${part.fileName}/${state.name}';

  Future createDirectoryIfNotExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      return;
    }
    await directory.create(recursive: true);
  }
}

Future<Uint8List> loadFileBytes(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return await file.readAsBytes();
  } else {
    throw FileSystemException('File not found: $filePath');
  }
}




