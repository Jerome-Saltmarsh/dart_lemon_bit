import 'classes.dart';
import 'classes/Block.dart';
import 'classes/Collectable.dart';
import 'classes/Crate.dart';
import 'classes/EnvironmentObject.dart';
import 'classes/Game.dart';
import 'classes/Item.dart';
import 'classes/Lobby.dart';
import 'classes/Player.dart';
import 'common/PlayerEvents.dart';
import 'common/Tile.dart';
import 'common/ServerResponse.dart';
import 'common/classes/Vector2.dart';
import 'instances/gameManager.dart';
import 'utils/player_utils.dart';

// constants
final int collectablesIndex = ServerResponse.Collectables.index;
final int playersIndex = ServerResponse.Players.index;
final int playerIndex = ServerResponse.Player.index;
final int indexZombies = ServerResponse.Zombies.index;
final int indexNpcs = ServerResponse.Npcs.index;
final int indexBullets = ServerResponse.Bullets.index;
final int indexNpcMessage = ServerResponse.NpcMessage.index;

const String _space = ' ';
const String _semiColon = '; ';
const String _comma = ', ';
const String _dash = '- ';
const int _1 = 1;
const int _0 = 0;

// public

int ySortPositioned(Positioned a, Positioned b){
  return a.y > b.y ? 1 : -1;
}

void compileGame(Game game) {
  game.buffer.clear();

  // game.players.sort(ySortPositioned);
  // game.zombies.sort(ySortPositioned);
  // game.npcs.sort(ySortPositioned);

  _compilePlayers(game.buffer, game.players);
  _compileZombies(game.buffer, game.zombies);
  _compileInteractableNpcs(game.buffer, game.npcs);
  _compileBullets(game.buffer, game.bullets);
  _compileGameEvents(game.buffer, game.gameEvents);
  _compileGrenades(game.buffer, game.grenades);
  _compileCollectables(game.buffer, game.collectables);

  _write(game.buffer, ServerResponse.Game_Time.index);
  _write(game.buffer, game.time);

  if (game.compilePaths) {
    _compilePaths(game.buffer, game.zombies);
    _compileNpcDebug(game.buffer, game.npcs);
  }

  _compileCrates(game);
  _compileItems(game.buffer, game.items);

  if (game is Fortress) {
    _compileFortress(game.buffer, game);
  }

  if (game is DeathMatch) {
    _compileDeathMatch(game.buffer, game);
  }

  game.compiled = game.buffer.toString();
}

String compileEnvironmentObjects(List<EnvironmentObject> environmentObjects) {
  StringBuffer buffer = StringBuffer();
  _write(buffer, ServerResponse.EnvironmentObjects.index);
  for (EnvironmentObject environmentObject in environmentObjects){
    _write(buffer, environmentObject.x.toInt());
    _write(buffer, environmentObject.y.toInt());
    _write(buffer, environmentObject.type.index);
  }
  _writeSemiColon(buffer);
  return buffer.toString();
}

void _compileCrates(Game game) {
  _write(game.buffer, ServerResponse.Crates.index);
  for (Crate crate in game.crates) {
    if (crate.deactiveDuration > 0) continue;
    _writeInt(game.buffer, crate.x);
    _writeInt(game.buffer, crate.y);
  }
  _write(game.buffer, _semiColon);
}

void _compileItems(StringBuffer buffer, List<Item> items) {
  _write(buffer, ServerResponse.Items.index);
  for (Item item in items) {
    _write(buffer, item.type.index);
    _writeInt(buffer, item.x);
    _write(buffer, item.y);
  }
  _write(buffer, _semiColon);
}

void _compileFortress(StringBuffer buffer, Fortress game) {
  _write(game.buffer, ServerResponse.MetaFortress.index);
  _write(game.buffer, game.lives);
  _write(game.buffer, game.wave);
  _write(game.buffer, game.nextWave);
}

void _compileDeathMatch(StringBuffer buffer, DeathMatch deathMatch) {
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

String compileTiles(List<List<Tile>> tiles) {
  StringBuffer buffer = StringBuffer();
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
  _write(buffer, playerIndex);
  _writeInt(buffer, player.x);
  _writeInt(buffer, player.y);
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
  _write(buffer, player.credits);
  _write(buffer, player.state.index);
  _writeBool(buffer, player.rounds.handgun > 0);
  _writeBool(buffer, player.acquiredShotgun);
  _writeBool(buffer, player.acquiredSniperRifle);
  _writeBool(buffer, player.acquiredAssaultRifle);
  _write(buffer, player.currentTile.index);
  _write(buffer, player.rounds.handgun);
  _write(buffer, player.rounds.shotgun);
  _write(buffer, player.rounds.sniperRifle);
  _write(buffer, player.rounds.assaultRifle);

  for (PlayerEvent playerEvent in player.events) {
    if (playerEvent.sent) continue;
    _compilePlayerEvents(buffer, player);
    return;
  }
}

void _compilePlayerEvents(StringBuffer buffer, Player player) {
  _write(buffer, ServerResponse.Player_Events.index);
  for (PlayerEvent playerEvent in player.events) {
    if (playerEvent.sent) continue;
    playerEvent.sent = true;
    _write(buffer, playerEvent.type.index);
    _write(buffer, playerEvent.value);
  }
  _write(buffer, _semiColon);
}

void compileScore(StringBuffer buffer, List<Player> players) {
  _write(buffer, ServerResponse.Score.index);
  for (Player player in players) {
    _write(buffer, player.name);
    _write(buffer, player.points);
    _write(buffer, player.pointsRecord);
  }
  _write(buffer, _semiColon);
}

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
  buffer.write(collectablesIndex);
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
      _writeInt(buffer, p.x);
      _writeInt(buffer, p.y);
    }
    _write(buffer, _comma);
  }
  buffer.write(_semiColon);
}

void _compileNpcDebug(StringBuffer buffer, List<Npc> npcs){
  _write(buffer, ServerResponse.NpcsDebug.index);
  for (Npc npc in npcs) {
    if (!npc.targetSet) continue;
    _writeInt(buffer, npc.x);
    _writeInt(buffer, npc.y);
    _writeInt(buffer, npc.target.x);
    _writeInt(buffer, npc.target.y);
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
  _write(buffer, playersIndex);
  for (Player player in players) {
    _compilePlayer(buffer, player);
  }
  buffer.write(_semiColon);
}

void _compileZombies(StringBuffer buffer, List<Npc> npcs) {
  _write(buffer, indexZombies);
  for (Npc npc in npcs) {
    if (!npc.active) continue;
    _compileNpc(buffer, npc);
  }
  buffer.write(_semiColon);
}

void _compileInteractableNpcs(StringBuffer buffer, List<InteractableNpc> npcs) {
  _write(buffer, indexNpcs);
  for (InteractableNpc npc in npcs) {
    if (!npc.active) continue;
    _compileInteractableNpc(buffer, npc);
  }
  buffer.write(_semiColon);
}

void _compileBullets(StringBuffer buffer, List<Bullet> bullets) {
  _write(buffer, indexBullets);
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
  _writeInt(buffer, player.x);
  _writeInt(buffer, player.y);
  _write(buffer, player.stateFrameCount);
  _write(buffer, player.weapon.index);
  _write(buffer, player.squad);
  _write(buffer, player.name);
  _write(buffer, player.text);
  _write(buffer, _comma);
}

void _compileNpc(StringBuffer buffer, Npc npc) {
  _write(buffer, npc.state.index);
  _write(buffer, npc.direction.index);
  _writeInt(buffer, npc.x);
  _writeInt(buffer, npc.y);
  _write(buffer, npc.stateFrameCount);
  _write(buffer, npc.pointMultiplier);
}

void _compileInteractableNpc(StringBuffer buffer, InteractableNpc npc) {
  _write(buffer, npc.state.index);
  _write(buffer, npc.direction.index);
  _writeInt(buffer, npc.x);
  _writeInt(buffer, npc.y);
  _write(buffer, npc.stateFrameCount);
  _write(buffer, npc.name);
}

void compilePlayerMessage(StringBuffer buffer, String message) {
  _write(buffer, indexNpcMessage);
  _write(buffer, message);
  _writeSemiColon(buffer);
}

void _writeSemiColon(StringBuffer buffer){
  _write(buffer, _semiColon);
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

void _writeBool(StringBuffer buffer, bool value) {
  _write(buffer, value ? _1 : _0);
}

void _writeInt(StringBuffer buffer, double value) {
  _write(buffer, value.toInt());
}

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(_space);
}
