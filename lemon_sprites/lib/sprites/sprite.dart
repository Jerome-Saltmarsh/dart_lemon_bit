
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_sprites/sprites/copy_paste.dart';
import 'package:lemon_sprites/sprites/draw_rec.dart';
import 'package:lemon_watch/src.dart';

import 'sprite_bounds.dart';


class Sprite {

  final rows = WatchInt(9);
  final columns = WatchInt(8);
  final image = Watch<Image?>(null);
  final bound = Watch<Image?>(null);
  final packed = Watch<Image?>(null);
  final grid = Watch<Image?>(null);
  final bounds = SpriteBounds();

  Sprite(){
    image.onChanged(onChangedImage);
    rows.onChanged(onChangedRows);
    columns.onChanged(onChangedColumn);
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
    bounds.capture(copy, rows.value, columns.value);
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

  void pack(){

    final img = image.value;

    if (img == null){
      throw Exception();
    }

    if (bounds.boundStackIndex <= 0){
      throw Exception();
    }

    var maxHeight = 0;
    var totalWidth = 0;

    for (var i = 0; i < bounds.boundStackIndex; i++){
      final height = bounds.boundStackBottom[i] - bounds.boundStackTop[i];
      final width = bounds.boundStackRight[i] - bounds.boundStackLeft[i];
      totalWidth += width;
      maxHeight = max(height, maxHeight);
    }

    final transparent = ColorRgba8(0, 0, 0, 0);
    final packedImage = Image(
        width: totalWidth + 100,
        height: maxHeight + 100,
        backgroundColor: transparent,
        numChannels: 4,
    );

    var x = 0;
    for (var i = 0; i < bounds.boundStackIndex; i++){
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
      x += width;
    }
    packed.value = packedImage;

    final previousArea = img.width * img.height;
    final newArea = packedImage.width * packedImage.height;
    print('image size reduced by ${100 - ((newArea / previousArea) * 100).toInt()}%');
  }
}

