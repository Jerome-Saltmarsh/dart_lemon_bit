import 'dart:math';

import 'dart:typed_data';

import 'package:fast_noise/fast_noise.dart';

import '../isometric_engine.dart';

class SceneGenerator {

  static Scene generate({
    required int height,
    required int rows,
    required int columns,
    required int altitude,
    required double frequency,
  }){
    altitude = min(altitude, height);

    final noise = noise2(rows, columns,
        noiseType: NoiseType.Perlin,
        frequency: frequency,
        cellularReturnType: CellularReturnType.Distance2Add,
    );

    final area = rows * columns;
    final volume = area * height;
    final nodeTypes = Uint8List(volume);
    final nodeOrientations = Uint8List(volume);

    final heightMap = Uint8List(area);
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final value = noise[row][column] + 1.0;
        final percentage = value * 0.5;
        var heightMapIndex = row * columns + column;
        heightMap[heightMapIndex] = (percentage * altitude).toInt();
        heightMapIndex++;
      }
    }

     for (var row = 0; row < rows; row++){
       for (var column = 0; column < columns; column++){
         var index = row * columns + column;
         final z = heightMap[index];

         if (z == 0){
           nodeTypes[index] = NodeType.Water;
           nodeOrientations[index] = NodeOrientation.None;
           continue;
         }

         final nodeIndex = (area * z) + index;
         nodeTypes[nodeIndex] = NodeType.Grass;
         nodeOrientations[nodeIndex] = NodeOrientation.Solid;
       }
     }

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns - 1; column++) {
         final heightMapIndex = row * columns + column;
         final heightMapValueA = heightMap[heightMapIndex];
         final heightMapValueB = heightMap[heightMapIndex + 1];
         final nodeIndex = (heightMapValueA * area) + heightMapIndex;

         if (nodeTypes[nodeIndex] != NodeType.Grass) {
           continue;
         }
         if (heightMapValueA == heightMapValueB) {
           continue;
         }

         if (heightMapValueA == heightMapValueB + 1){
           nodeOrientations[nodeIndex] = NodeOrientation.Slope_East;
           continue;
         }
         if (heightMapValueA == heightMapValueB - 1){
           nodeOrientations[nodeIndex + area] = NodeOrientation.Slope_West;
           nodeTypes[nodeIndex + area] = NodeType.Grass;
           continue;
         }
      }
    }

    return Scene(
        name: "",
        types: nodeTypes,
        shapes: nodeOrientations,
        height: height,
        rows: rows,
        columns: columns,
        gameObjects: [],
        marks: [],
        variations: Uint8List(volume),

     );
  }


}