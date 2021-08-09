import 'classes.dart';
import 'classes/Game.dart';
import 'enums.dart';
import 'settings.dart';
import 'state.dart';

void compileState(Game game) {
  game.buffer.clear();
  _compilePlayers(game.buffer, game.players);
  _compileNpcs(game.buffer, game.npcs);
  _compileBullets(game.buffer, game.bullets);
  _compileGameEvents(game.buffer, game.gameEvents);
  _compileGrenades(game.buffer, game.grenades);
  game.compiled = game.buffer.toString();
}

void _compileGameEvents(StringBuffer buffer, List<GameEvent> gameEvents) {
  if (gameEvents.isEmpty) return;
  _write(buffer, "events:");
  for (GameEvent gameEvent in gameEvents) {
    _write(buffer, gameEvent.id);
    _write(buffer, gameEvent.type.index);
    _write(buffer, gameEvent.x.toInt());
    _write(buffer, gameEvent.y.toInt());
    _write(buffer, gameEvent.xv.toStringAsFixed(1));
    _write(buffer, gameEvent.yv.toStringAsFixed(1));
  }
  _end(buffer);
}

void _compileGrenades(StringBuffer buffer, List<Grenade> grenades){
  _write(buffer, 'grenades');
  for(Grenade grenade in grenades){
    _write(buffer, grenade.x.toInt());
    _write(buffer, grenade.y.toInt());
    _write(buffer, grenade.z.toStringAsFixed(1));
  }
  _end(buffer);
}

String compileTiles(StringBuffer buffer, List<List<Tile>> tiles) {
  buffer.write("tiles: ");
  buffer.write(tiles.length);
  buffer.write(" ");
  buffer.write(tiles[0].length);
  buffer.write(" ");
  for (int x = 0; x < tiles.length; x++) {
    for (int y = 0; y < tiles[0].length; y++) {
      buffer.write(tiles[x][y].index);
      buffer.write(" ");
    }
  }
  buffer.write("; ");
  return buffer.toString();
}

void compilePlayer(StringBuffer buffer, Player player) {
  buffer.write("player ");
  buffer.write(player.health.toStringAsFixed(2));
  buffer.write(' ');
  buffer.write(player.maxHealth.toStringAsFixed(2));
  buffer.write(' ');
  buffer.write(player.stamina);
  buffer.write(' ');
  buffer.write(player.maxStamina);
  buffer.write(' ');
  buffer.write(player.handgunAmmunition.clips);
  buffer.write(' ');
  buffer.write(player.handgunAmmunition.clipSize);
  buffer.write(' ');
  buffer.write(player.handgunAmmunition.maxClips);
  buffer.write(' ');
  buffer.write(player.handgunAmmunition.rounds);
  buffer.write(' ; ');
}

// void _compileFPS() {
//   buffer.write("fms: ${frameDuration.inMilliseconds} ;");
// }

// void _compileFrame() {
//   buffer.write('f: $frame ; ');
// }

void _compilePlayers(StringBuffer buffer, List<Player> players) {
  _write(buffer, "p:");
  players.forEach((player) => _compileCharacter(buffer, player));
  _end(buffer);
}

void _compileNpcs(StringBuffer buffer, List<Npc> npcs) {
  _write(buffer, "n:");
  npcs.forEach((npc) => _compileNpc(buffer, npc));
  _end(buffer);
}

void _compileBullets(StringBuffer buffer, List<Bullet> bullets) {
  _write(buffer, "b:");
  bullets.forEach((bullet) => _compileBullet(buffer, bullet));
  _end(buffer);
}

void _compileBullet(StringBuffer buffer, Bullet bullet) {
  _write(buffer, bullet.id);
  _write(buffer, bullet.x);
  _write(buffer, bullet.y);
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
  _write(buffer, npc.x.toStringAsFixed(compilePositionDecimals));
  _write(buffer, npc.y.toStringAsFixed(compilePositionDecimals));
}

void _write(StringBuffer buffer, dynamic value) {
  buffer.write(value);
  buffer.write(" ");
}

void _end(StringBuffer buffer) {
  buffer.write("; ");
}
