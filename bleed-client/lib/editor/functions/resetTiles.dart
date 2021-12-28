import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';

void newScene() {
  for (int row = 0; row < game.tiles.length; row++) {
    for (int column = 0; column < game.tiles[0].length; column++) {
      game.tiles[row][column] = editState.tile;
    }
  }
  game.crates.clear();
  game.particleEmitters.clear();
  game.environmentObjects.clear();
  game.collectables.clear();
  game.items.clear();
  mapTilesToSrcAndDst(game.tiles);
}

void resetTiles({
  required int rows,
  required int columns,
}){
  game.totalRows = rows;
  game.totalColumns = columns;
  game.tiles.clear();
  for (int row = 0; row < rows; row++) {
    List<Tile> columnTiles = [];
    for (int column = 0; column < columns; column++) {
      columnTiles.add(Tile.Grass);
    }
    game.tiles.add(columnTiles);
  }
  game.crates.clear();
  game.particleEmitters.clear();
  game.environmentObjects.clear();
  game.collectables.clear();
  game.items.clear();
  mapTilesToSrcAndDst(game.tiles);
}