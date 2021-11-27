import 'classes/Projectile.dart';
import 'classes/Collectable.dart';
import 'classes/Crate.dart';
import 'classes/EnvironmentObject.dart';
import 'classes/Game.dart';
import 'classes/GameEvent.dart';
import 'classes/Grenade.dart';
import 'classes/Item.dart';
import 'classes/Npc.dart';
import 'classes/Player.dart';
import 'classes/InteractableNpc.dart';
import 'classes/Weapon.dart';
import 'common/PlayerEvents.dart';
import 'common/Tile.dart';
import 'common/ServerResponse.dart';
import 'common/classes/Vector2.dart';
import 'games/world.dart';
import 'utils/player_utils.dart';

// constants
final int _collectablesIndex = ServerResponse.Collectables.index;
final int _playersIndex = ServerResponse.Players.index;
final int _playerIndex = ServerResponse.Player.index;
final int _indexZombies = ServerResponse.Zombies.index;
final int _indexNpcs = ServerResponse.Npcs.index;
final int _indexBullets = ServerResponse.Bullets.index;
final int _indexNpcMessage = ServerResponse.NpcMessage.index;

const String _space = ' ';
const String _semiColon = '; ';
const String _comma = ', ';
const int _1 = 1;
const int _0 = 0;

void compileGame(Game game) {
  game.buffer.clear();

  _compilePlayers(game.buffer, game.players);
  _compileZombies(game.buffer, game.zombies);
  _compileInteractableNpcs(game.buffer, game.npcs);
  _compileProjectiles(game.buffer, game.projectiles);
  _compileGameEvents(game.buffer, game.gameEvents);
  _compileGrenades(game.buffer, game.grenades);
  _compileCollectables(game.buffer, game.collectables);

  _write(game.buffer, ServerResponse.Game_Time.index);
  _write(game.buffer, time);

  if (game.compilePaths) {
    _compilePaths(game.buffer, game.zombies);
    _compileNpcDebug(game.buffer, game.npcs);
  }

  _write(game.buffer, ServerResponse.Scene_Shade_Max.index);
  _write(game.buffer, game.shadeMax.index);

  _compileCrates(game);
  _compileItems(game.buffer, game.items);

  game.compiled = game.buffer.toString();
}

String compileEnvironmentObjects(List<EnvironmentObject> environmentObjects) {
  StringBuffer buffer = StringBuffer();
  _write(buffer, ServerResponse.EnvironmentObjects.index);
  for (EnvironmentObject environmentObject in environmentObjects){
    _writeInt(buffer, environmentObject.x);
    _writeInt(buffer, environmentObject.y);
    _writeInt(buffer, environmentObject.radius);
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

void compileWeapons(StringBuffer buffer, List<Weapon> weapons){
  _write(buffer, ServerResponse.Weapons.index);
  _write(buffer, weapons.length);
  for(Weapon weapon in weapons){
    compileWeapon(buffer, weapon);
  }
}

void compileWeapon(StringBuffer buffer, Weapon weapon){
  _write(buffer, weapon.type.index);
  _write(buffer, weapon.rounds);
  _write(buffer, weapon.capacity);
  _write(buffer, weapon.damage);
}

void compilePlayer(StringBuffer buffer, Player player) {
  _write(buffer, _playerIndex);
  _writeInt(buffer, player.x);
  _writeInt(buffer, player.y);
  _write(buffer, player.weapon.type.index);
  _write(buffer, player.health.toInt());
  _write(buffer, player.maxHealth.toInt());
  _write(buffer, player.grenades);
  _write(buffer, player.weapon.rounds);
  _write(buffer, player.weapon.capacity);
  _write(buffer, player.state.index);
  _write(buffer, player.currentTile.index);

  _compilePlayerEvents(buffer, player);
}

void _compilePlayerEvents(StringBuffer buffer, Player player) {

  int total = 0;

  for (PlayerEvent event in player.events) {
    if (event.sent) continue;
    total++;
  }

  if (total == 0) return;

  _write(buffer, ServerResponse.Player_Events.index);
  _write(buffer, total);
  for (PlayerEvent event in player.events) {
    if (event.sent) continue;
    event.sent = true;
    _write(buffer, event.type.index);
    _write(buffer, event.value);
  }
}

void compileScore(StringBuffer buffer, List<Player> players) {
  _write(buffer, ServerResponse.Score.index);
  for (Player player in players) {
    _write(buffer, player.name);
    _write(buffer, player.pointsRecord);
  }
  _write(buffer, _semiColon);
}

void _compileGameEvents(StringBuffer buffer, List<GameEvent> gameEvents) {
  _write(buffer, ServerResponse.Game_Events.index);
  for (GameEvent gameEvent in gameEvents) {
    if (gameEvent.frameDuration <= 0) continue;
    _write(buffer, gameEvent.id);
    _write(buffer, gameEvent.type.index);
    _writeInt(buffer, gameEvent.x);
    _writeInt(buffer, gameEvent.y);
    _write(buffer, gameEvent.xv.toStringAsFixed(1));
    _write(buffer, gameEvent.yv.toStringAsFixed(1));
  }
  buffer.write(_semiColon);
}

void _compileCollectables(StringBuffer buffer, List<Collectable> collectables) {
  buffer.write(_collectablesIndex);
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
  _write(buffer, _playersIndex);
  for (Player player in players) {
    _compilePlayer(buffer, player);
  }
  buffer.write(_semiColon);
}

void _compileZombies(StringBuffer buffer, List<Npc> npcs) {
  _write(buffer, _indexZombies);
  int total = 0;
  for (Npc npc in npcs) {
    if (npc.active) total++;
  }
  _write(buffer, total);
  for (Npc npc in npcs) {
    if (!npc.active) continue;
    _compileNpc(buffer, npc);
  }
}

void _compileInteractableNpcs(StringBuffer buffer, List<InteractableNpc> npcs) {
  _write(buffer, _indexNpcs);
  for (InteractableNpc npc in npcs) {
    if (!npc.active) continue;
    _compileInteractableNpc(buffer, npc);
  }
  buffer.write(_semiColon);
}

void _compileProjectiles(StringBuffer buffer, List<Projectile> bullets) {
  _write(buffer, _indexBullets);
  for (Projectile bullet in bullets) {
    if (!bullet.active) continue;
    _compileProjectile(buffer, bullet);
  }
  buffer.write(_semiColon);
}

void _compileProjectile(StringBuffer buffer, Projectile projectile) {
  _write(buffer, projectile.x.toInt());
  _write(buffer, projectile.y.toInt());
  _write(buffer, projectile.type.index);
  _write(buffer, projectile.direction.index);
}

void _compilePlayer(StringBuffer buffer, Player player) {
  _write(buffer, player.state.index);
  _write(buffer, player.direction.index);
  _writeInt(buffer, player.x);
  _writeInt(buffer, player.y);
  _write(buffer, player.stateFrameCount);
  _write(buffer, player.weapon.type.index);
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
  _write(buffer, _indexNpcMessage);
  _write(buffer, message);
  _writeSemiColon(buffer);
}

void _writeSemiColon(StringBuffer buffer){
  _write(buffer, _semiColon);
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
