import 'classes.dart';
import 'classes/Block.dart';
import 'classes/Collectable.dart';
import 'classes/Game.dart';
import 'classes/Inventory.dart';
import 'classes/Player.dart';
import 'enums.dart';
import 'enums/ServerResponse.dart';

// constants

const String _space = ' ';
const String _semiColon = '; ';

// public

void compileState(Game game) {
  game.buffer.clear();
  game.buffer.write(game.gameIdString);
  _compilePlayers(game.buffer, game.players);
  _compileNpcs(game.buffer, game.npcs);
  _compileBullets(game.buffer, game.bullets);
  _compileGameEvents(game.buffer, game.gameEvents);
  _compileGrenades(game.buffer, game.grenades);
  _compileCollectables(game.buffer, game.collectables);
  game.compiled = game.buffer.toString();
}

void compileBlocks(StringBuffer buffer, List<Block> blocks) {
  buffer.write(ServerResponse.Blocks.index);
  buffer.write(_space);
  for (Block block in blocks) {
    _write(buffer, block.topX.toInt());
    _write(buffer, block.topY.toInt());
    _write(buffer, block.rightX.toInt());
    _write(buffer, block.rightY.toInt());
    _write(buffer, block.bottomX.toInt());
    _write(buffer, block.bottomY.toInt());
    _write(buffer, block.leftX.toInt());
    _write(buffer, block.leftY.toInt());
  }
  buffer.write(_semiColon);
}

String compileTiles(StringBuffer buffer, List<List<Tile>> tiles) {
  buffer.write(ServerResponse.Tiles.index);
  buffer.write(_space);
  buffer.write(tiles.length);
  buffer.write(_space);
  buffer.write(tiles[0].length);
  buffer.write(_space);
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      buffer.write(tiles[x][y].index);
      buffer.write(_space);
    }
  }
  buffer.write(_semiColon);
  return buffer.toString();
}

void compilePlayer(StringBuffer buffer, Player player) {
  _write(buffer, ServerResponse.Player.index);
  _write(buffer, player.x.toInt());
  _write(buffer, player.y.toInt());
  _write(buffer, player.weapon.index);
  _write(buffer, player.health.toInt());
  _write(buffer, player.maxHealth.toInt());
  _write(buffer, player.stamina);
  _write(buffer, player.maxStamina);
  _write(buffer, player.handgunRounds);
  _write(buffer, player.shotgunRounds);
  _compileInventory(buffer, player.inventory);
}

void _compileInventory(StringBuffer buffer, Inventory inventory) {
  _write(buffer, ServerResponse.Inventory.index);
  _write(buffer, inventory.rows);
  _write(buffer, inventory.columns);
  for (InventoryItem item in inventory.items) {
    _write(buffer, item.type.index);
    _write(buffer, item.row);
    _write(buffer, item.column);
  }
  buffer.write(_semiColon);
}

// private

void _compileGameEvents(StringBuffer buffer, List<GameEvent> gameEvents) {
  _write(buffer, ServerResponse.Game_Events.index);
  for (GameEvent gameEvent in gameEvents) {
    _write(buffer, gameEvent.id);
    _write(buffer, gameEvent.type.index);
    _write(buffer, gameEvent.x.toInt());
    _write(buffer, gameEvent.y.toInt());
    _write(buffer, gameEvent.xv.toStringAsFixed(1));
    _write(buffer, gameEvent.yv.toStringAsFixed(1));
  }
  buffer.write(_semiColon);
}

void _compileCollectables(StringBuffer buffer, List<Collectable> collectables) {
  buffer.write(ServerResponse.Collectables.index);
  buffer.write(_space);
  for (Collectable collectable in collectables) {
    if (!collectable.active) continue;
    buffer.write(collectable.compiled);
  }
  buffer.write(_semiColon);
}

void _compileGrenades(StringBuffer buffer, List<Grenade> grenades) {
  buffer.write(ServerResponse.Grenades.index);
  buffer.write(_space);
  for (Grenade grenade in grenades) {
    _write(buffer, grenade.x.toInt());
    _write(buffer, grenade.y.toInt());
    _write(buffer, grenade.z.toStringAsFixed(1));
  }
  buffer.write(_semiColon);
}

void _compilePlayers(StringBuffer buffer, List<Player> players) {
  buffer.write(ServerResponse.Players.index);
  buffer.write(_space);
  for (Player player in players) {
    _compileCharacter(buffer, player);
  }

  buffer.write(_semiColon);
}

void _compileGameId(StringBuffer buffer, Game game) {
  _write(game.buffer, '${ServerResponse.Game_Id.index} ${game.id} ;');
}

void _compileNpcs(StringBuffer buffer, List<Npc> npcs) {
  buffer.write(ServerResponse.Npcs.index);
  buffer.write(_space);
  for (Npc npc in npcs) {
    _compileNpc(buffer, npc);
  }
  buffer.write(_semiColon);
}

void _compileBullets(StringBuffer buffer, List<Bullet> bullets) {
  buffer.write(ServerResponse.Bullets.index);
  buffer.write(_space);
  for (Bullet bullet in bullets) {
    _compileBullet(buffer, bullet);
  }
  buffer.write(_semiColon);
}

void _compileBullet(StringBuffer buffer, Bullet bullet) {
  _write(buffer, bullet.x.toInt());
  _write(buffer, bullet.y.toInt());
}

void _compileCharacter(StringBuffer buffer, Character character) {
  _write(buffer, character.state.index);
  _write(buffer, character.direction.index);
  _write(buffer, character.x.toInt());
  _write(buffer, character.y.toInt());
  _write(buffer, character.id);
  _write(buffer, character.weapon.index);
}

void _compileNpc(StringBuffer buffer, Npc npc) {
  _write(buffer, npc.state.index);
  _write(buffer, npc.direction.index);
  _write(buffer, npc.x.toInt());
  _write(buffer, npc.y.toInt());
}

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(_space);
}
