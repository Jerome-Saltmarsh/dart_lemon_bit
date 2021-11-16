import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:bleed_client/state/game.dart';

void newScene() {
  for (int row = 0; row < game.tiles.length; row++) {
    for (int column = 0; column < game.tiles[0].length; column++) {
      game.tiles[row][column] = editState.tile;
    }
  }
  game.crates.clear();
  game.particleEmitters.clear();
  game.backgroundObjects.clear();
  game.environmentObjects.clear();
  game.collectables.clear();
  game.items.clear();
  renderTiles(game.tiles);
}