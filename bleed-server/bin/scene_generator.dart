
import 'package:fast_noise/fast_noise.dart';
import 'package:lemon_math/random.dart';
import 'package:lemon_math/randomItem.dart';

import 'classes/EnvironmentObject.dart';
import 'classes/Scene.dart';
import 'common/ObjectType.dart';
import 'common/Tile.dart';

typedef TileMap = List<List<int>>;

Scene generateRandomScene() {
  const totalColumns = 100;
  const totalRows = 100;
  final noiseMap = noise2(
      totalColumns,
      totalRows,
      seed: random.nextInt(2000),
      noiseType: NoiseType.Perlin,
      octaves: 10,
      frequency: 0.040,
      cellularReturnType: CellularReturnType.Distance2Add
  );

  final tiles = <List<int>>[];
  final environment = <EnvironmentObject>[];
  for (var columnIndex = 0; columnIndex < totalColumns; columnIndex++) {
    final noiseColumn = noiseMap[columnIndex];
    final column = <int>[];
    tiles.add(column);
    for (var rowIndex = 0; rowIndex < totalRows; rowIndex++) {
       final noise = noiseColumn[rowIndex];
       if (noise < 0.0001) {
         column.add(Tile.Water);
       }
       else
       if (noise < 0.4) {
         column.add(Tile.Grass);
         if (random.nextDouble() < 0.05) {
           const halfTileSize = 24.0;
           final px = perspectiveProjectX(columnIndex * halfTileSize, rowIndex * halfTileSize);
           final py = perspectiveProjectY(columnIndex * halfTileSize, rowIndex * halfTileSize) + halfTileSize;
           environment.add(EnvironmentObject(x: px, y: py, type: randomItem(const [
             ObjectType.Tree01,
             ObjectType.Tree01,
             ObjectType.Rock,
           ])));
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
      name: 'random-map',
  );
}

