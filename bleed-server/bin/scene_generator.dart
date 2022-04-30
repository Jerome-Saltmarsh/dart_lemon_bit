
import 'package:fast_noise/fast_noise.dart';
import 'package:lemon_math/library.dart';

import 'classes/DynamicObject.dart';
import 'classes/EnvironmentObject.dart';
import 'classes/Scene.dart';
import 'common/DynamicObjectType.dart';
import 'common/ObjectType.dart';
import 'common/Tile.dart';

typedef TileMap = List<List<int>>;

Scene generateRandomScene({
  required int columns,
  required int rows,
  int seed = 0,
}) {
  final noiseMap = noise2(
      columns,
      rows,
      seed: seed,
      noiseType: NoiseType.Perlin,
      octaves: 3,
      frequency: 0.05,
  );

  final tiles = <List<int>>[];
  final environment = <EnvironmentObject>[];
  final dynamicObjects = <DynamicObject>[];
  for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
    final noiseColumn = noiseMap[columnIndex];
    final column = <int>[];
    tiles.add(column);
    for (var rowIndex = 0; rowIndex < rows; rowIndex++) {
       final noise = noiseColumn[rowIndex];
       if (noise < -0.15) {
         column.add(Tile.Water);
       }
       else
       if (noise < 0.4) {

         if (random.nextDouble() < 0.01) {
           column.add(Tile.Long_Grass);
         } else {
           column.add(Tile.Grass);
         }
         if (random.nextDouble() < 0.05) {
           const halfTileSize = 24.0;
           final px = perspectiveProjectX(columnIndex * halfTileSize, rowIndex * halfTileSize);
           final py = perspectiveProjectY(columnIndex * halfTileSize, rowIndex * halfTileSize) + halfTileSize;
           environment.add(
               EnvironmentObject(x: px, y: py, type: randomItem(const [
                 ObjectType.Tree01,
                 ObjectType.Tree01,
                 ObjectType.Rock,
                 ObjectType.Tree_Stump,
                 ObjectType.LongGrass,
               ]))
           );
         }
         else
         if (random.nextDouble() < 0.001) {
           const halfTileSize = 24.0;
           dynamicObjects.add(
               DynamicObject(
                 type: DynamicObjectType.Chest,
                 x: perspectiveProjectX(columnIndex * halfTileSize, rowIndex * halfTileSize),
                 y: perspectiveProjectY(columnIndex * halfTileSize, rowIndex * halfTileSize) + halfTileSize,
                 health: 50
           ));
         }
       } else {
         column.add(Tile.Block_Grass);
       }
    }
  }

  return Scene(
      tiles: tiles,
      crates: [],
      environment: environment,
      characters: [],
      dynamicObjects: dynamicObjects,
      name: 'random-map',
  );
}

