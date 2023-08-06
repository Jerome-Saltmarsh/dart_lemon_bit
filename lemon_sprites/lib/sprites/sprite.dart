
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

  var fileName = '';
  var packStack = Uint16List(0);

  final rows = WatchInt(8);
  final columns = WatchInt(8);
  final file = Watch<PlatformFile?>(null);
  final image = Watch<Image?>(null);
  final bound = Watch<Image?>(null);
  final packed = Watch<Image?>(null);
  final grid = Watch<Image?>(null);
  final bounds = SpriteBounds();

  Sprite(){
    file.onChanged(onChangedFile);
    image.onChanged(onChangedImage);
  }

  void onChangedFile(PlatformFile? file){
    if (file == null){
      clearPackedImage();
      return;
    }

    final bytes = file.bytes;
    if (bytes == null){
      throw Exception();
    }
    final now = DateTime.now();
    image.value = decodePng(bytes);
    final ms = DateTime.now().difference(now).inMilliseconds;
    print('decodePng took $ms milliseconds');
    fileName = file.name;
  }

  void onChangedImage(Image? image){
    clearPackedImage();
  }

  void clearPackedImage() {
    bound.value = null;
    packed.value = null;
  }

  void bind(){
    final source = image.value;

    if (source == null){
      throw Exception('source image is null');
    }
    final copy = source.clone();
    bounds.bind(copy, rows.value, columns.value);
    final total = bounds.boundStackIndex;
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

    bound.value = copy;

  }

  var packStackIndex = 0;

  void pack(){

    final img = image.value;

    if (img == null){
      throw Exception();
    }

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

    final transparent = ColorRgba8(0, 0, 0, 0);

    canvasHeight += 200;

    final packedImage = Image(
      width: canvasWidth,
      height: canvasHeight,
      backgroundColor: transparent,
      numChannels: 4,
    );

    var j = 4;
    for (var i = 0; i < totalBounds; i++){
      final srcLeft = stackLeft[i];
      final srcTop = stackTop[i];
      final pasteLeft = packStack[j++];
      final pasteTop = packStack[j++];
      final pasteRight = packStack[j++];
      final pasteBottom = packStack[j++];
      final pasteDstX = packStack[j++];
      final pasteDstY = packStack[j++];

      final width = pasteRight - pasteLeft;
      final height = pasteBottom - pasteTop;

      if (pasteDstX + width >= canvasWidth){
        throw Exception();
      }

      if (pasteDstY + height >= canvasHeight){
        throw Exception();
      }

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

    packed.value = packedImage;
  }

  void writeToPackStack(int value){
    packStack[packStackIndex++] = value;
  }

  void save() {
    final imgPacked = packed.value;
    if (imgPacked == null){
      throw Exception();
    }
    downloadBytes(bytes: encodePng(imgPacked), name: fileName.replaceAll('.png', '_packed.png'));

    downloadBytes(
        bytes: packStack.buffer.asUint8List(),
        name: fileName.replaceAll('.png', '_packed.sprite'),
    );
  }


}

