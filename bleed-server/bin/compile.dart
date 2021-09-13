import 'classes.dart';
import 'classes/Block.dart';
import 'classes/Collectable.dart';
import 'classes/Game.dart';
import 'classes/Inventory.dart';
import 'classes/Lobby.dart';
import 'classes/Player.dart';
import 'classes/Vector2.dart';
import 'common/GameState.dart';
import 'enums.dart';
import 'common/ServerResponse.dart';
import 'instances/gameManager.dart';
import 'utils/player_utils.dart';

// constants

const String _space = ' ';
const String _semiColon = '; ';
const String _comma = ', ';
const String _dash = '- ';

// public

void compileGame(Game game) {
  game.buffer.clear();
  _compilePlayers(game.buffer, game.players);
  _compileNpcs(game.buffer, game.npcs);
  _compileBullets(game.buffer, game.bullets);
  _compileGameEvents(game.buffer, game.gameEvents);
  _compileGrenades(game.buffer, game.grenades);
  _compileCollectables(game.buffer, game.collectables);
  // _compilePaths(game.buffer, game.npcs);

  // if (game.gameOver()) {
  //   _write(game.buffer, ServerResponse.GameOver.index);
  // }

  if (game is Fortress) {
    _compileFortress(game.buffer, game);
  }

  if (game is DeathMatch) {
    _compileDeathMatch(game.buffer, game);
  }

  game.compiled = game.buffer.toString();
}

void _compileFortress(StringBuffer buffer, Fortress game) {
  _write(game.buffer, ServerResponse.MetaFortress.index);
  _write(game.buffer, game.lives);
  _write(game.buffer, game.wave);
  _write(game.buffer, game.nextWave);
}

void _compileDeathMatch(StringBuffer buffer, DeathMatch deathMatch){
  _write(buffer, ServerResponse.MetaDeathMatch.index);
  _write(buffer, deathMatch.numberOfAlivePlayers);
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
  _write(buffer, player.grenades);
  _write(buffer, player.meds);
  _write(buffer, player.lives);
  _write(buffer, equippedWeaponClips(player));
  _write(buffer, equippedWeaponRounds(player));
  _write(buffer, player.gameState.index);
  _write(buffer, player.points);
  // _compileInventory(buffer, player.inventory);
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

void _compilePaths(StringBuffer buffer, List<Npc> npcs) {
  _write(buffer, ServerResponse.Paths.index);
  for (Npc npc in npcs) {
    if (npc.path.isEmpty) continue;
    for (Vector2 p in npc.path) {
      _write(buffer, p.x.toInt());
      _write(buffer, p.y.toInt());
    }
    _write(buffer, _comma);
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
  _write(buffer, ServerResponse.Players.index);
  for (Player player in players) {
    _compilePlayer(buffer, player);
  }
  buffer.write(_semiColon);
}

void _compileNpcs(StringBuffer buffer, List<Npc> npcs) {
  _write(buffer, ServerResponse.Npcs.index);
  for (Npc npc in npcs) {
    if (!npc.active) continue;
    _compileNpc(buffer, npc);
  }
  buffer.write(_semiColon);
}

void _compileBullets(StringBuffer buffer, List<Bullet> bullets) {
  _write(buffer, ServerResponse.Bullets.index);
  for (Bullet bullet in bullets) {
    if (!bullet.active) continue;
    _compileBullet(buffer, bullet);
  }
  buffer.write(_semiColon);
}

void _compileBullet(StringBuffer buffer, Bullet bullet) {
  _write(buffer, bullet.x.toInt());
  _write(buffer, bullet.y.toInt());
}

void _compilePlayer(StringBuffer buffer, Player player) {
  _write(buffer, player.state.index);
  _write(buffer, player.direction.index);
  _write(buffer, player.x.toInt());
  _write(buffer, player.y.toInt());
  _write(buffer, player.stateFrameCount);
  _write(buffer, player.weapon.index);
  _write(buffer, player.squad);
  _write(buffer, player.name);
}

void _compileNpc(StringBuffer buffer, Npc npc) {
  _write(buffer, npc.state.index);
  _write(buffer, npc.direction.index);
  _write(buffer, npc.x.toInt());
  _write(buffer, npc.y.toInt());
  _write(buffer, npc.stateFrameCount);
}

void compileLobby(StringBuffer buffer, Lobby lobby) {
  _write(buffer, lobby.maxPlayers);
  _write(buffer, lobby.players.length);
  _write(buffer, lobby.uuid);
  _write(buffer, lobby.name ?? _dash);
  if (lobby.game != null) {
    _write(buffer, lobby.game!.uuid);
  } else {
    _write(buffer, _dash);
  }
}

String compileLobbies() {
  StringBuffer buffer = StringBuffer();
  _write(buffer, ServerResponse.Lobby_List.index);
  for (Lobby lobby in lobbies) {
    compileLobby(buffer, lobby);
  }
  _write(buffer, _semiColon);
  return buffer.toString();
}

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(_space);
}
