
import 'package:fast_noise/fast_noise.dart';
import 'package:lemon_math/library.dart';

import 'classes/DynamicObject.dart';
import 'classes/EnvironmentObject.dart';
import 'classes/Scene.dart';
import 'common/DynamicObjectType.dart';
import 'common/ObjectType.dart';
import 'common/Tile.dart';

Scene generateRandomScene({
  required int rows,
  required int columns,
  int seed = 0,
}) {
  final noiseMap = noise2(
      rows,
      columns,
      seed: seed,
      noiseType: NoiseType.Perlin,
      octaves: 3,
      frequency: 0.05,
  );

  final tiles = <List<int>>[];
  final environment = <StaticObject>[];
  final dynamicObjects = <DynamicObject>[];
  for (var rowIndex = 0; rowIndex < rows; rowIndex++) {
    final noiseColumn = noiseMap[rowIndex];
    final column = <int>[];
    tiles.add(column);
    for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
       final noise = noiseColumn[columnIndex];
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
           environment.add(
               StaticObject(
                   x: getTilePositionX(columnIndex, rowIndex),
                   y: getTilePositionY(columnIndex, rowIndex),
                   type: randomItem(const [
                     ObjectType.Tree01,
                     ObjectType.Tree01,
                     ObjectType.Rock,
                     ObjectType.Tree_Stump,
                     ObjectType.LongGrass,
                   ])
               )
           );
       }
         else
         if (random.nextDouble() < 0.001) {
           dynamicObjects.add(
               DynamicObject(
                 type: DynamicObjectType.Chest,
                   x: getTilePositionX(columnIndex, rowIndex),
                   y: getTilePositionY(columnIndex, rowIndex),
                   health: 50
           ));
         }
       } else if (noise < 0.6) {
         column.add(Tile.Block_Grass);
       } else {
         column.add(Tile.Block_Grass_Level_2);
       }
    }
  }

  return Scene(
      tiles: tiles,
      crates: [],
      staticObjects: environment,
      characters: [],
      dynamicObjects: dynamicObjects,
      name: 'random-map',
  );
}

