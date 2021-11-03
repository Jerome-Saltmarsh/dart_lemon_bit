import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/state.dart';

void resetTiles() {
  for (int row = 0; row < compiledGame.tiles.length; row++) {
    for (int column = 0; column < compiledGame.tiles[0].length; column++) {
      compiledGame.tiles[row][column] = Tile.Grass;
    }
  }
  compiledGame.crates.clear();
  compiledGame.collectables.clear();
  compiledGame.items.clear();
  renderTiles(compiledGame.tiles);
}