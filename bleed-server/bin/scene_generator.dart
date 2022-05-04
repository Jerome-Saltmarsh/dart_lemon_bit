
import 'package:fast_noise/fast_noise.dart';
import 'package:lemon_math/library.dart';

import 'classes/DynamicObject.dart';
import 'classes/EnvironmentObject.dart';
import 'classes/Scene.dart';
import 'common/DynamicObjectType.dart';
import 'common/ObjectType.dart';
import 'common/Tile.dart';
import 'enums.dart';
import 'utilities.dart';

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
                   x: getTilePositionX(rowIndex, columnIndex),
                   y: getTilePositionY(rowIndex, columnIndex),
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
                   x: getTilePositionX(rowIndex, columnIndex),
                   y: getTilePositionY(rowIndex, columnIndex),
                   health: 50
           ));
         }
       } else if (noise < 0.55) {
         column.add(Tile.Block_Grass);
       } else if (noise < 0.65) {
         column.add(Tile.Block_Grass_Level_2);
       } else {
         column.add(Tile.Block_Grass_Level_3);
       }
    }
  }

  final cells = <List<Cell>>[];
  for (var row = 0; row < rows; row++) {
    final cellRow = <Cell>[];
    cells.add(cellRow);
    for (var column = 0; column < columns; column++) {
       cellRow.add(
           Cell(
               row: row,
               column: column,
               open: isWalkable(tiles[row][column]),
           )
       );
    }
  }

  var land = 0;
  final landSizes = <int, int> { };
  landSizes[land] = 0;

  void visitCell(int row, int column) {
    if (row < 0) return;
    if (column < 0) return;
    if (row >= rows) return;
    if (column >= columns) return;
    final cell = cells[row][column];
    if (!cell.visitable) return;
    cell.land = land;
    landSizes[land] = (landSizes[land] ?? 0) + 1;
    visitCell(row - 1, column);
    visitCell(row + 1, column);
    visitCell(row, column - 1);
    visitCell(row, column + 1);
  }

  for (var row = 0; row < rows; row++){
    for (var column = 0; column < columns; column++) {
      final cell = cells[row][column];
      if (!cell.visitable) continue;
      visitCell(row, column);
      land++;
    }
  }

  var biggestCellLandSize = -1;
  var biggestCellLandSizeId = -1;

  for (final size in landSizes.entries){
     if (size.value < biggestCellLandSize) continue;
     biggestCellLandSize = biggestCellLandSize;
     biggestCellLandSizeId = size.key;
  }

  for (final size in landSizes.entries){
    if (size == biggestCellLandSize) continue;
  }

  final numberOfSpawnPoints = 5;
  final spawnCells = <SpawnCell>[];

  for (var i = 0; i < numberOfSpawnPoints; i++) {
    final row = randomInt(0, rows);
    final column = randomInt(0, columns);
    if (!isWalkable(tiles[row][column])) {
      i--;
      continue;
    }
    final cell = cells[row][column];
    final cellLand = cell.land;
    if (cellLand == null) throw Exception('cell.land is null');
    if (cellLand != biggestCellLandSizeId) {
      continue;
    }
    spawnCells.add(SpawnCell(row, column));
  }

  return Scene(
      tiles: tiles,
      staticObjects: environment,
      characters: [],
      dynamicObjects: dynamicObjects,
      name: 'random-map',
      playerSpawnPoints: spawnCells
          .map((e) => Vector2(getTilePositionX(e.row, e.column),
              getTilePositionY(e.row, e.column)))
          .toList());
}

class Cell {
   late final int row;
   late final int column;
   late final bool open;
   int? land;
   Cell({
     required this.row,
     required this.column,
     required this.open,
   });

   bool get visitable => open && land == null;
}

class SpawnCell {
  late final int row;
  late final int column;
  SpawnCell(this.row, this.column);
}

