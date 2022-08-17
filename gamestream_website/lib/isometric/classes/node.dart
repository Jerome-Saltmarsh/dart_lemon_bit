
import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:bleed_common/wind.dart';
import 'package:lemon_engine/actions/render_atlas.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

import '../constants/color_pitch_black.dart';

abstract class Node {
  var bake = 0;
  var shade = 0;
  var _wind = 0;
  var dstX = 0.0;
  var dstY = 0.0;
  var visible = true;

  void hide(){
    visible = false;
  }

  set wind (int value){
     _wind = clamp(value, 0, windIndexStrong);
  }

  void applyLight(int value){
    assert (value >= 0);
    assert (value <= Shade.Pitch_Black);
    if (shade <= value) return;
    shade = value;
  }

  void applyLight1(){
    if (shade <= 0) return;
    applyLight(shade - 1);
  }

  int get wind => _wind;

  bool get emitsLight => false;

  Node(int row, int column, int z) {
     dstX = (row - column) * tileSizeHalf;
     dstY = ((row + column) * tileSizeHalf) - (z * tileHeight);
  }

  int get type;
  String get name => GridNodeType.getName(type);
  bool get isEmpty => false;
  bool get isRainable => false;
  bool get renderable => true;
  bool get blocksPerception => true;
  bool get isShadable => true;

  void resetShadeToBake(){
    shade = bake;
  }

  static final boundary = NodeBoundary();
  static final empty = NodeEmpty();

  void handleRender();

  void renderSrcX(double srcX){
    const spriteWidth = 48.0;
    const spriteHeight = 72.0;
    const spriteWidthHalf = spriteWidth * 0.5;
    const spriteHeightThird = 24.0;

    var srcY = shade * spriteHeight;

    src[bufferIndex] = srcX;
    dst[bufferIndex] = 1;
    colors[renderIndex] = 0;

    bufferIndex++;

    src[bufferIndex] = srcY;
    dst[bufferIndex] = 0;

    bufferIndex++;

    src[bufferIndex] = srcX + spriteWidth;
    dst[bufferIndex] = dstX - spriteWidthHalf;

    bufferIndex++;

    src[bufferIndex] = srcY + spriteHeight;
    dst[bufferIndex] = dstY - spriteHeightThird;

    bufferIndex++;
    renderIndex++;

    if (bufferIndex < buffers) return;
    bufferIndex = 0;
    renderIndex = 0;
    renderAtlas();
  }

  void renderShaded(double srcX){
    const spriteWidth = 48.0;
    const spriteHeight = 72.0;
    const spriteWidthHalf = spriteWidth * 0.5;
    const spriteHeightThird = 24.0;

    src[bufferIndex] = srcX;
    dst[bufferIndex] = 1;
    colors[renderIndex] = colorShades[shade];

    bufferIndex++;

    src[bufferIndex] = 0;
    dst[bufferIndex] = 0;

    bufferIndex++;

    src[bufferIndex] = srcX + spriteWidth;
    dst[bufferIndex] = dstX - spriteWidthHalf;

    bufferIndex++;

    src[bufferIndex] = spriteHeight;
    dst[bufferIndex] = dstY - spriteHeightThird;

    bufferIndex++;
    renderIndex++;

    if (bufferIndex < buffers) return;
    bufferIndex = 0;
    renderIndex = 0;
    renderAtlas();
  }

}

class NodeBoundary extends Node {
  NodeBoundary() : super(0, 0, 0) {
    visible = false;
  }

  @override
  void handleRender() {
     throw Exception("Cannot render boundary");
  }

  @override
  bool get renderable => false;

  @override
  int get type => GridNodeType.Boundary;

  @override
  bool get blocksPerception => false;

  @override
  bool get isShadable => false;
}

class NodeEmpty extends Node {
  NodeEmpty() : super(0, 0, 0);

  @override
  void handleRender() {
    // do nothing
  }

  set wind (int value){
    // do nothing
    // print("ignored");
  }

  @override
  bool get isShadable => false;

  @override
  void hide(){
    // do nothing
  }

  @override
  void resetShadeToBake(){
    // do nothing
  }

  @override
  bool get blocksPerception => false;

  @override
  bool get renderable => false;

  @override
  int get type => GridNodeType.Empty;

  @override
  bool get isEmpty => true;
}

abstract class GridNodeColorRamp extends Node {

  GridNodeColorRamp({
    required int row,
    required int column,
    required int z,
  }) : super(row, column, z);

  @override
  void handleRender() => renderSrcX(srcX);

  double get srcX;
}

abstract class GridNodeShaded extends Node {

  GridNodeShaded({
    required int row,
    required int column,
    required int z,
  }) : super(row, column, z);

  @override
  void handleRender() => renderShaded(srcX);

  double get srcX;
}
