import 'dart:math';

import 'package:fast_noise/fast_noise.dart';
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';

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
    var heightMapIndex = 0;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final value = noise[row][column] + 1.0;
        final percentage = value * 0.5;
        heightMap[heightMapIndex] = (percentage * altitude).toInt();
        heightMapIndex++;
      }
    }

    var index = 0;
     for (var row = 0; row < rows; row++){
       for (var column = 0; column < columns; column++){
         final value = noise[row][column] + 1.0;
         final percentage = value * 0.5;
         final h = (percentage * altitude).toInt();

         if (h == 0){
           nodeTypes[index] = NodeType.Water;
           nodeOrientations[index] = NodeOrientation.None;
           index++;
           continue;
         }

         // for (var i = 0; i < h; i++) {
         //   final iIndex = index + (i * area);
         //   nodeTypes[iIndex] = NodeType.Grass;
         //   nodeOrientations[iIndex] = NodeOrientation.Solid;
         // }
         final indexA = (area * h) + (row * columns + column);
         nodeTypes[indexA] = NodeType.Grass;
         nodeOrientations[indexA] = NodeOrientation.Solid;

         index++;
       }
     }

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns - 1; column++) {
         final i = row * columns + column;
         final heightA = heightMap[i];
         final heightB = heightMap[i + 1];
         if (heightA == heightB) continue;
         final indexA = area * heightA + i;
         if (heightA - 1 == heightB){
           assert (nodeTypes[indexA] == NodeType.Grass);
           nodeOrientations[indexA] = NodeOrientation.Slope_East;
         }
      }
    }

    return Scene(
        name: "",
        nodeTypes: nodeTypes,
        nodeOrientations: nodeOrientations,
        gridHeight: height,
        gridRows: rows,
        gridColumns: columns,
        gameObjects: [],
        spawnPointsPlayers: Uint16List(0),
        spawnPointTypes: Uint16List(0),
        spawnPoints: Uint16List(0),
     );
  }
}