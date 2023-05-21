
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' as mat;
import 'package:vector_math/vector_math.dart';

class Game3D {

  static final square = Model.square(size: 100);

  static void renderCanvas(Canvas canvas, Size size) {

    Engine3D.renderModel(canvas, square);

    // Engine3D.renderTriangle(
    //     canvas: canvas,
    //     x1: 200, y1: 200, x2: 300, y2: 300, x3: 200, y3: 300, color: mat.Colors.red.value,
    // );
    //
    // Engine3D.renderTriangle(
    //   canvas: canvas,
    //   x1: 500, y1: 500, x2: 800, y2: 800, x3: 500, y3: 800, color: mat.Colors.green.value,
    // );
  }
}

class Model {
  late List<Vector3> vertices;
  /// a flat list of 4 vertex indexes
  late Uint16List polygons;

  Model({required this.vertices, required this.polygons});

  Model.square({required double size}){
    vertices = [
      // bottom
      Vector3(0.0, 0.0, 0.0),
      Vector3(size, 0.0, 0.0),
      Vector3(size, size, 0.0),
      Vector3(0.0, size, 0.0),
      // top
      Vector3(0.0, 0.0, size),
      Vector3(size, 0.0, size),
      Vector3(size, size, size),
      Vector3(0.0, size, size),
    ];
    polygons = Uint16List.fromList([
      0, 1, 2, 3
    ]);
  }
}

class Engine3D {
  static final paint = Paint()
    ..color = mat.Colors.red
    ..style = PaintingStyle.fill
    ..strokeWidth = 2.0;

  static void renderTriangle({
    required Canvas canvas,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double x3,
    required double y3,
    required int color,
  }){

    final positions = Float32List(6);
    final indices = Uint16List.fromList([0, 1, 2]);
    final colors = Int32List(3);
    positions[0] = x1;
    positions[1] = y1;
    positions[2] = x2;
    positions[3] = y2;
    positions[4] = x3;
    positions[5] = y3;
    colors[0] = color;
    colors[1] = color;
    colors[2] = color;

    final vertexObject = Vertices.raw(
      VertexMode.triangles,
      positions,
      colors: colors,
      indices: indices,
    );

    canvas.drawVertices(vertexObject, BlendMode.dstATop, paint);
  }

  static void renderModel(Canvas canvas, Model model){
    assert (model.polygons.length % 4 == 0);
    final polygons = model.polygons;
    final vertices = model.vertices;

    for (var i = 0; i < polygons.length; i += 4) {

      final v1 = vertices[polygons[i + 0]];
      final v2 = vertices[polygons[i + 1]];
      final v3 = vertices[polygons[i + 2]];
      final v4 = vertices[polygons[i + 3]];

      final v1XProjected = v1.x; // project

      renderTriangle(
        canvas: canvas,
        x1: v3.x,
        y1: v3.y,
        x2: v4.x,
        y2: v4.y,
        x3: v1.x,
        y3: v1.y,
        color: mat.Colors.blue.value,
      );

      renderTriangle(
        canvas: canvas,
        x1: v1.x,
        y1: v1.y,
        x2: v2.x,
        y2: v2.y,
        x3: v3.x,
        y3: v3.y,
        color: mat.Colors.red.value,
      );
    }
  }
}
