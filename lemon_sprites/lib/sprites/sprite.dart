
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

  final rows = WatchInt(8);
  final columns = WatchInt(8);
  final image = Watch<Image?>(null);
  final bound = Watch<Image?>(null);
  final packed = Watch<Image?>(null);
  final grid = Watch<Image?>(null);
  final bounds = SpriteBounds();
  var fileName = '';

  Sprite(){
    image.onChanged(onChangedImage);
    rows.onChanged(onChangedRows);
    columns.onChanged(onChangedColumn);
  }

  void setImageFile(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null){
      throw Exception();
    }
    image.value = decodePng(bytes);
    fileName = file.name;
  }

  void onChangedRows(int rows){
    buildGrid();
  }

  void onChangedColumn(int rows){
    buildGrid();
  }

  void setImageFromBytes(Uint8List bytes) {
    image.value = decodePng(bytes);
  }

  void onChangedImage(Image? image){
    clearPackedImage();
    buildGrid();
  }

  void clearPackedImage() {
    bound.value = null;
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

  void buildGrid() {
    return;
    final src = image.value;
    if (src == null){
      grid.value = null;
      return;
    }

    final transparent = ColorRgba8(0, 0, 0, 0);
    final width = src.width;
    final height = src.height;
    final gridImage = Image(
        width: width,
        height: height,
        backgroundColor: transparent,
        numChannels: 4,
    );

    final rows = this.rows.value;
    final columns = this.columns.value;

    final cellWidth = width ~/ columns;
    final cellHeight = height ~/ rows;
    final black = ColorRgba8(0, 0, 0, 255);

    for (var row = 0; row < rows; row++) {
      for (var x = 0; x < width; x++){
        final y = row * cellHeight;
        gridImage.setPixel(x, y, black);
      }
    }
    for (var column = 0; column < columns; column++) {
      for (var y = 0; y < height; y++){
        final x = column * cellWidth;
        gridImage.setPixel(x, y, black);
      }
    }
    grid.value = gridImage;
  }

  var packStack = Uint16List(0);

  void pack(){

    final img = image.value;

    if (img == null){
      throw Exception();
    }

    if (bounds.boundStackIndex <= 0){
      throw Exception();
    }

    var maxHeight = 0;
    var totalWidth = bounds.boundStackIndex; // padding left

    for (var i = 0; i < bounds.boundStackIndex; i++){
      final height = bounds.boundStackBottom[i] - bounds.boundStackTop[i];
      final width = bounds.boundStackRight[i] - bounds.boundStackLeft[i];
      totalWidth += width;
      maxHeight = max(height, maxHeight);
    }

    final transparent = ColorRgba8(0, 0, 0, 0);
    final packedImage = Image(
        width: totalWidth,
        height: maxHeight,
        backgroundColor: transparent,
        numChannels: 4,
    );

    final spriteWidth = bounds.spriteWidth;
    final spriteHeight = bounds.spriteHeight;

    var x = 0;
    var y = 0;
    final totalBounds = bounds.boundStackIndex;
    packStack = Uint16List(totalBounds * 6);
    var packStackIndex = 0;

    for (var i = 0; i < totalBounds; i++){
      final left = bounds.boundStackLeft[i];
      final right = bounds.boundStackRight[i];
      final top = bounds.boundStackTop[i];
      final bottom = bounds.boundStackBottom[i];
      final width = right - left;
      final height = bottom - top;

      copyPaste(
          srcImage: img,
          dstImage: packedImage,
          width: width,
          height: height,
          srcX: left,
          srcY: top,
          dstX: x,
          dstY: 0,
      );

      final dstX = left % spriteWidth;
      final dstY = top % spriteHeight;

      packStack[packStackIndex++] = x;
      packStack[packStackIndex++] = y;
      packStack[packStackIndex++] = x + width;
      packStack[packStackIndex++] = y + height;
      packStack[packStackIndex++] = dstX;
      packStack[packStackIndex++] = dstY;

      x += width;
      x++;
    }
    packed.value = packedImage;
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

