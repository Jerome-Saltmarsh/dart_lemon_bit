
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
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
  var orientation = NodeOrientation.None;

  int get color => colorShades[shade];

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
  String get name => NodeType.getName(type);
  bool get isEmpty => false;
  bool get isRainable => orientation == NodeOrientation.Solid;
  bool get renderable => true;
  bool get blocksPerception => true;
  bool get isShadable => true;

  bool get isStone => false;
  bool get isWood => false;
  bool get isSpawn => type == NodeType.Spawn;

  void resetShadeToBake(){
    shade = bake;
  }

  static final boundary = NodeBoundary();
  static final empty = NodeEmpty();

  void handleRender();

  /// Renders a custom shade
  void renderShadeManual(double srcX) {
    const spriteHeight = 72.0;
    renderStandardNode(srcX, shade * spriteHeight);
  }

  /// Use this to render dynamically
  void renderShadeAuto(double x, [double y = 0]) {
    renderStandardNode(x, y, color);
  }

  void renderStandardNode(double srcX, double srcY, [int color = 0]){
    const spriteWidth = 48.0;
    const spriteHeight = 72.0;
    const spriteWidthHalf = spriteWidth * 0.5;
    const spriteHeightThird = 24.0;

    src[bufferIndex] = srcX;
    dst[bufferIndex] = 1;
    colors[renderIndex] = color;

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
  int get type => NodeType.Boundary;

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
  int get type => NodeType.Empty;

  @override
  bool get isEmpty => true;
}

abstract class NodeShadeManual extends Node {

  NodeShadeManual({
    required int row,
    required int column,
    required int z,
  }) : super(row, column, z);

  @override
  void handleRender() => renderShadeManual(srcX);

  double get srcX;
}

abstract class NodeShadeAuto extends Node {

  NodeShadeAuto({
    required int row,
    required int column,
    required int z,
  }) : super(row, column, z);

  @override
  void handleRender() => renderShadeAuto(srcX, 0);

  double get srcX;
}


/// Use this to render dynamically
void renderNodeShadeAuto(Node node, double x, [double y = 0]) {
  node.renderStandardNode(x, y, node.color);
}

// remove Node.renderNode method,