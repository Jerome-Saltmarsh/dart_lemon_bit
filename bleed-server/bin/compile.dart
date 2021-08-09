import 'classes.dart';
import 'settings.dart';
import 'state.dart';

void compileState() {
  buffer.clear();
  _compilePlayers();
  _compileNpcs();
  _compileBullets();
  _compileFPS();
  _compileFrame();
  _compileGameEvents();
  _compileGrenades();
  compiledState = buffer.toString();
}

void _compileGameEvents() {
  if (gameEvents.isEmpty) return;
  _write("events:");
  for (GameEvent gameEvent in gameEvents) {
    _write(gameEvent.id);
    _write(gameEvent.type.index);
    _write(gameEvent.x.toInt());
    _write(gameEvent.y.toInt());
    _write(gameEvent.xv.toStringAsFixed(1));
    _write(gameEvent.yv.toStringAsFixed(1));
  }
  _end();
}

void _compileGrenades(){
  _write('grenades');
  for(Grenade grenade in grenades){
    _write(grenade.x.toInt());
    _write(grenade.y.toInt());
    _write(grenade.z.toStringAsFixed(1));
  }
  _end();
}

String compileTiles() {
  StringBuffer buffer = StringBuffer();
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

String compilePlayer(Player player) {
  StringBuffer buffer = StringBuffer();
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
  buffer.write(compiledState);
  return buffer.toString();
}

void _compileFPS() {
  buffer.write("fms: ${frameDuration.inMilliseconds} ;");
}

void _compileFrame() {
  buffer.write('f: $frame ; ');
}

void _compilePlayers() {
  _write("p:");
  players.forEach(_compileCharacter);
  _end();
}

void _compileNpcs() {
  _write("n:");
  npcs.forEach(_compileNpc);
  _end();
}

void _compileBullets() {
  _write("b:");
  bullets.forEach(_compileBullet);
  _end();
}

void _compileBullet(Bullet bullet) {
  _write(bullet.id);
  _write(bullet.x);
  _write(bullet.y);
}

void _compileCharacter(Character character) {
  _write(character.state.index);
  _write(character.direction.index);
  _write(character.x.toInt());
  _write(character.y.toInt());
  _write(character.id);
  _write(character.weapon.index);
}

void _compileNpc(Npc npc) {
  _write(npc.state.index);
  _write(npc.direction.index);
  _write(npc.x.toStringAsFixed(compilePositionDecimals));
  _write(npc.y.toStringAsFixed(compilePositionDecimals));
}

void _write(dynamic value) {
  buffer.write(value);
  buffer.write(" ");
}

void _end() {
  buffer.write("; ");
}
