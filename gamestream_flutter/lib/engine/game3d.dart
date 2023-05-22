
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'game.dart';

class Game3D implements Game {
  @override
  Widget buildUI(BuildContext context) {
    // TODO: implement buildUI
    throw UnimplementedError();
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    final positions = Float32List(16);
    final size = 50.0;

    positions[0] = 0;
    positions[1] = 0;

    positions[2] = 0;
    positions[3] = size;

    positions[4] = size;
    positions[5] = size;

    positions[6] = size;
    positions[7] = 0;

    final indices = Uint16List(8);
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 3;
    indices[4] = 4;
    indices[5] = 5;
    indices[6] = 6;
    indices[7] = 7;

    final colors = Int32List(8);
    colors[0] = Colors.red.value;
    colors[1] = Colors.yellow.value;
    colors[2] = Colors.blue.value;
    colors[3] = Colors.green.value;
    colors[4] = Colors.green.value;
    colors[5] = Colors.green.value;
    colors[6] = Colors.green.value;
    colors[7] = Colors.green.value;

    // Create the vertices object using Vertices.raw
    final vertexObject = Vertices.raw(
      VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );

    // Create the paint object
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw the cube on the canvas using drawVertices
    canvas.drawVertices(vertexObject, BlendMode.src, paint);
  }

  @override
  void onActivated() {
    // TODO: implement onActivated
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    // TODO: implement renderForeground
  }

  @override
  void update() {
    // TODO: implement update
  }

}