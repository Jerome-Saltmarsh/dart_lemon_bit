import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/constants.dart';
import 'package:bleed_common/enums/ObjectType.dart';
import 'package:bleed_common/enums/ProjectileType.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:bleed_common/tileTypeToObjectType.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/mappers/mapTileToSrcRect.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/constants.dart';
import 'package:gamestream_flutter/modules/isometric/properties.dart';
import 'package:gamestream_flutter/modules/isometric/queries.dart';
import 'package:gamestream_flutter/modules/isometric/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_engine/engine.dart';

import 'utilities.dart';

final _dynamic = isometric.state.dynamic;
final _tilesSrc = isometric.state.tilesSrc;
final _maxRow = isometric.state.maxRow;
final _maxColumn =  isometric.state.maxRow;
final _rowIndex16 = isometric.state.totalColumnsInt * 16;
final _minRow = isometric.state.minRow;
final _minColumn = isometric.state.minColumn;

class IsometricActions {

  final IsometricState state;
  final IsometricQueries queries;
  final IsometricConstants constants;
  final IsometricProperties properties;
  final _atlasTilesX = atlas.tiles.x;
  final _atlasTilesY = atlas.tiles.y;

  IsometricActions(this.state, this.queries, this.constants, this.properties);

  void refreshGeneratedObjects() {
    final tiles = state.tiles;
    final totalRows = tiles.length;
    final totalColumns = totalRows > 0 ? tiles[0].length : 0;
    for (var rowIndex = 0; rowIndex < totalRows; rowIndex++) {
       final row = tiles[rowIndex];
       for (var columnIndex = 0; columnIndex < totalColumns; columnIndex++){
         final tile = row[columnIndex];
         var objectType = tileTypeToObjectType[tile];
         if (objectType == null) continue;

         if (objectType == ObjectType.Palisade) {
              if (rowIndex > 0 && rowIndex < totalRows -1) {
                  if (tiles[rowIndex - 1][columnIndex] == Tile.Palisade && tiles[rowIndex + 1][columnIndex] == Tile.Palisade) {
                      objectType = ObjectType.Palisade_H;
                  }
              }

              if (columnIndex > 0 && columnIndex < totalColumns - 1) {
                if (row[columnIndex -1] == Tile.Palisade && row[columnIndex + 1] == Tile.Palisade) {
                  objectType = ObjectType.Palisade_V;
                }
              }
         }

         final env = EnvironmentObject(
             x: getTileWorldX(rowIndex, columnIndex),
             y: getTileWorldY(rowIndex, columnIndex) + halfTileSize,
             type: objectType,
             radius: 0
         );
         state.environmentObjects.add(env);
       }
    }
  }
}