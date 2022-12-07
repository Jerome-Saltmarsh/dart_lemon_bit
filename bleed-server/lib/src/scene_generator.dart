import 'package:fast_noise/fast_noise.dart';
import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';

class SceneGenerator {

  static Scene generate({
    required int height,
    required int rows,
    required int columns,
    required int octaves,
    required double frequency,
  }){
    final noise = noise2(rows, columns,
        noiseType: NoiseType.Perlin,
        octaves: octaves,
        frequency: frequency,
        cellularReturnType: CellularReturnType.Distance2Add,
    );

     final area = rows * columns;
     final volume = area * height;
     final nodeTypes = Uint8List(volume);
     final nodeOrientations = Uint8List(volume);

     var index = 0;
     for (var row = 0; row < rows; row++){
       for (var column = 0; column < columns; column++){
         final value = noise[row][column] + 1.0;
         final percentage = value * 0.5;
         const maxHeight = 4;
         final h = (percentage * maxHeight).toInt();

         if (h == 0){
           nodeTypes[index] = NodeType.Water;
           nodeOrientations[index] = NodeOrientation.None;
           index++;
           continue;
         }

         for (var i = 0; i < h; i++) {
           final iIndex = index + (i * area);
           nodeTypes[iIndex] = NodeType.Grass;
           nodeOrientations[iIndex] = NodeOrientation.Solid;
         }
         index++;
       }
     }


     return Scene(
        name: "random",
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