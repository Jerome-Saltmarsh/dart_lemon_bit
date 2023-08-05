
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_sprites/sprites/draw_rec.dart';
import 'package:lemon_watch/src.dart';

import 'sprite_bounds.dart';


class Sprite {

  final rows = WatchInt(9);
  final columns = WatchInt(8);
  final image = Watch<Image?>(null);
  final packedImage = Watch<Image?>(null);
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
    packedImage.value = null;
  }

  void pack(){
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

    packedImage.value = copy;

  }

  void buildGrid() {
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
}

