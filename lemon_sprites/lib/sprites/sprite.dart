
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart';
import 'package:lemon_sprites/sprites/copy_paste.dart';
import 'package:lemon_sprites/sprites/draw_rec.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'sprite_bounds.dart';


class Sprite {

  static const maxSize = 2048;

  var packStackIndex = 0;
  var fileName = '';
  var packStack = Uint16List(0);

  final rows = WatchInt(8);
  final columns = WatchInt(8);
  final bounds = SpriteBounds();
  final reduction = Watch(0);

  final transparent = ColorRgba8(0, 0, 0, 0);
  final previewBound = Watch<Image?>(null);
  final previewPacked = Watch<Image?>(null);
  final previewGrid = Watch<Image?>(null);

  Image? _image;

  final imageSet = Watch(false);
  final imageWatch = Watch<Image?>(null);

  set file(PlatformFile? value){

    if (value == null){
      clearPackedImage();
      return;
    }

    final bytes = value.bytes;
    if (bytes == null){
      throw Exception();
    }
    image = decodePng(bytes);
    fileName = value.name;

  }

  Image? get image => _image;

  set image(Image? value){
    _image = value;
    imageSet.value = value != null;
    imageWatch.value = value;
    clearPackedImage();
  }

  void clearPackedImage() {
    previewBound.value = null;
    previewPacked.value = null;
    reduction.value = 0;
  }

  void bind(Image image, {required bool drawPreview}){
    final copy = drawPreview ? image.clone() : image;
    bounds.bind(copy, rows.value, columns.value);
    final total = bounds.boundStackIndex;

    if (drawPreview){
      final color = ColorRgb8(255, 0, 0);
      for (var i = 0; i < total; i++){
        drawRec(
          image: copy,
          left: bounds.boundStackLeft[i],
          top: bounds.boundStackTop[i],
          right: bounds.boundStackRight[i],
          bottom: bounds.boundStackBottom[i],
          color: color,
        );
      }
      previewBound.value = copy;
    }

    if (drawPreview){
      final previousArea = (image.width * image.height).toInt();
      final boundArea = bounds.totalArea;
      reduction.value = ((1 - (boundArea / previousArea)) * 100).toInt();
    }
  }

  Image pack(Image img){

    if (bounds.boundStackIndex <= 0){
      throw Exception();
    }

    final spriteWidth = bounds.spriteWidth;
    final spriteHeight = bounds.spriteHeight;

    final stackLeft = bounds.boundStackLeft;
    final stackTop = bounds.boundStackTop;
    final stackRight = bounds.boundStackRight;
    final stackBottom = bounds.boundStackBottom;

    var canvasWidth = 0;
    var canvasHeight = 0;
    var rowHeight = 0;

    var pasteX = 0;
    var pasteY = 0;
    final totalBounds = bounds.boundStackIndex;
    packStack = Uint16List(4 + (totalBounds * 6));
    packStackIndex = 0;
    writeToPackStack(spriteWidth);
    writeToPackStack(spriteHeight);
    writeToPackStack(rows.value);
    writeToPackStack(columns.value);

    for (var i = 0; i < totalBounds; i++) {
      final srcLeft = stackLeft[i];
      final srcRight = stackRight[i];
      final scrTop = stackTop[i];
      final srcBottom = stackBottom[i];
      final width = srcRight - srcLeft;
      final height = srcBottom - scrTop;

      rowHeight = max(height, rowHeight);

      if (pasteX + width > maxSize){
        pasteX = 0;
        pasteY += rowHeight + 1;
        rowHeight = height;
      }

      canvasHeight = max(canvasHeight, pasteY + rowHeight);

      packStack[packStackIndex++] = pasteX;
      packStack[packStackIndex++] = pasteY;
      packStack[packStackIndex++] = pasteX + width;
      packStack[packStackIndex++] = pasteY + height;
      packStack[packStackIndex++] = srcLeft % spriteWidth;
      packStack[packStackIndex++] = scrTop % spriteHeight;
      pasteX += width;
      pasteX++;
      canvasWidth = max(canvasWidth, pasteX);
    }

    final packedImage = Image(
      width: canvasWidth,
      height: canvasHeight,
      backgroundColor: transparent,
      numChannels: 4,
    );

    if (canvasHeight > maxSize){
      throw Exception('canvas height exceeds max height');
    }

    var j = 4; // the first four indexes are used to store width, height, columns and rows
    for (var i = 0; i < totalBounds; i++){
      final srcLeft = stackLeft[i];
      final srcTop = stackTop[i];
      final pasteLeft = packStack[j++];
      final pasteTop = packStack[j++];
      final pasteRight = packStack[j++];
      final pasteBottom = packStack[j++];
      packStack[j++];
      packStack[j++];

      final width = pasteRight - pasteLeft;
      final height = pasteBottom - pasteTop;

      copyPaste(
        srcImage: img,
        dstImage: packedImage,
        width: width,
        height: height,
        srcX: srcLeft,
        srcY: srcTop,
        dstX: pasteLeft,
        dstY: pasteTop,
      );
    }

    return packedImage;
  }

  void writeToPackStack(int value){
    packStack[packStackIndex++] = value;
  }

  void save() {
    final imgPacked = previewPacked.value;
    if (imgPacked == null){
      throw Exception();
    }
    downloadBytes(bytes: encodePng(imgPacked), name: fileName);

    downloadBytes(
        bytes: packStack.buffer.asUint8List(),
        name: fileName.replaceAll('.png', '.sprite'),
    );
  }

  Future buildAtlas() async {
    final files = await loadFilesFromDisk();
    if (files == null) {
      return;
    }

    final spriteSheets = <SpriteSheet>[];

    print('building spritesheets');

    for (final file in files) {
      final bytes = file.bytes;
      if (bytes == null){
        throw Exception();
      }

      final imageDecoded = decodePng(bytes) ?? (throw Exception());
      bind(imageDecoded, drawPreview: false);
      final imagePacked = pack(imageDecoded);

      spriteSheets.add(
        SpriteSheet(
            image: imagePacked,
            bounds: packStack.buffer.asUint8List(),
            name: file.name,
        )
      );
    }

    print('compiling spritesheets');
    var width = 0;
    var height = 0;

    for (final spriteSheet in spriteSheets){
      height += spriteSheet.image.height + 1;
      width = max(width, spriteSheet.image.width);
    }

    height--;

    final atlas = Image(
        width: width,
        height: height,
        backgroundColor: transparent,
        numChannels: 4,
    );

    var row = 0;

    for (final spriteSheet in spriteSheets){
      final image = spriteSheet.image;
      final imageHeight = image.height;
      final imageWidth = image.width;

      for (var y = 0; y < imageHeight; y++){
         for (var x = 0; x < imageWidth; x++){

           if (x >= atlas.width){
             throw Exception();
           }
           if (row >= atlas.height){
             throw Exception();
           }

           atlas.setPixel(x, row, image.getPixel(x, y));
         }
         row++;
      }
    }
    downloadBytes(bytes: encodePng(atlas), name: 'atlas.png');
  }

  void loadFiles(List<PlatformFile> files) async {
    files.forEach(process);
  }

  void process(PlatformFile file) async {
    this.file = file;
    fileName = file.name;
    final bytes = file.bytes;
    if (bytes == null){
      throw Exception();
    }
    final decodedImage = decodePng(bytes) ?? (throw Exception());
    bind(decodedImage, drawPreview: true);
    previewPacked.value = pack(decodedImage);
    save();
  }
}

class SpriteSheet {
   final Image image;
   final Uint8List bounds;
   final String name;

  SpriteSheet({
    required this.image,
    required this.bounds,
    required this.name,
  });
}