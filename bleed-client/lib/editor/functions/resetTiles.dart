import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/state/environmentObjects.dart';
import 'package:bleed_client/state/game.dart';

void newScene() {
  for (int row = 0; row < game.tiles.length; row++) {
    for (int column = 0; column < game.tiles[0].length; column++) {
      game.tiles[row][column] = Tile.Grass;
    }
  }
  game.crates.clear();
  game.particleEmitters.clear();
  game.backgroundObjects.clear();
  environmentObjects.clear();
  game.collectables.clear();
  game.items.clear();
  renderTiles(game.tiles);
}