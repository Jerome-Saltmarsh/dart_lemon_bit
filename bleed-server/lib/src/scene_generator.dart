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

         assert (nodeTypes[nodeIndex] != NodeType.Empty);

         if (heightMapValueA == heightMapValueB) continue;
         if (heightMapValueA - 1 == heightMapValueB){
           assert (nodeTypes[nodeIndex] == NodeType.Grass);
           nodeOrientations[nodeIndex] = NodeOrientation.Slope_East;
           continue;
         }
         // if (heightMapValueA + 1 == heightMapValueB){
         //   assert (nodeTypes[nodeIndex] == NodeType.Grass);
         //   nodeOrientations[nodeIndex] = NodeOrientation.Slope_West;
         //   continue;
         // }
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