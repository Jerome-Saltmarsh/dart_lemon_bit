import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/render/functions/mapTilesToSrcAndDst.dart';
import 'package:bleed_client/state/game.dart';

void resetTiles() {
  newScene(rows: game.totalRows, columns: game.totalColumns);
}

void newScene({
  required int rows,
  required int columns,
  Tile tile = Tile.Grass,
}){
  game.totalRows = rows;
  game.totalColumns = columns;
  game.tiles.clear();
  for (int row = 0; row < rows; row++) {
    List<Tile> columnTiles = [];
    for (int column = 0; column < columns; column++) {
      columnTiles.add(tile);
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