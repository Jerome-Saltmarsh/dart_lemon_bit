
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

class Model {
  /// a flat list of x,y,z values
  late Float32List vertices;
  /// a flat list of 4 vertex indexes
  late Uint16List polygons;
}

class GameCube {

  /// a face is comprised of 4 vertices


  static void renderCanvas(Canvas canvas, Size size) {

    final positions = Float32List(6);
    final size = 50.0;

    positions[0] = 100;
    positions[1] = 0;

    positions[2] = 0;
    positions[3] = size;

    positions[4] = size;
    positions[5] = size;

    final indices = Uint16List(3);
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    // indices[3] = 3;
    // indices[4] = 4;
    // indices[5] = 5;
    // indices[6] = 6;
    // indices[7] = 7;

    final colors = Int32List(3);
    colors[0] = Colors.green.value;
    colors[1] = Colors.green.value;
    colors[2] = Colors.green.value;

    // Create the vertices object using Vertices.raw
    final vertexObject = Vertices.raw(
      VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );

    // Create the paint object
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;


    canvas.drawVertices(vertexObject, BlendMode.dstATop, paint);
  }
}