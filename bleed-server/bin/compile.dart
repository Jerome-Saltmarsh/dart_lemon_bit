import 'classes.dart';
import 'settings.dart';
import 'state.dart';

void compileState() {
  buffer.clear();
  _compilePlayers();
  _compileNpcs();
  _compileBullets();
  _compilePasses();
  _compileFPS();
  _compileFrame();
  _compileGameEvents();
  _compileBlood();
  _compileParticles();
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

String compilePlayer(Character character) {
  StringBuffer buffer = StringBuffer();
  buffer.write("player: ");
  buffer.write(character.health.toStringAsFixed(2));
  buffer.write(' ');
  buffer.write(character.maxHealth.toStringAsFixed(2));
  buffer.write(' ; ');
  buffer.write(compiledState);
  return buffer.toString();
}

String compilePass(int value) {
  return 'pass: $value ; ';
}

void _compileFPS() {
  buffer.write("fms: ${frameDuration.inMilliseconds} ;");
}

void _compilePasses() {
  buffer.write("passes: $firstPass $secondPass $thirdPass $fourthPass ; ");
}

void _compileFrame() {
  buffer.write('f: $frame ; ');
}

void _compilePlayers() {
  _write("p:");
  players.forEach(_compileCharacter);
  _end();
}

void _compileBlood() {
  _write('blood:');
  blood.forEach((drop) {
    _write(drop.x.toInt());
    _write(drop.y.toInt());
  });
  _end();
}

void _compileParticles() {
  _write('particles');
  particles.forEach((particle) {
    _write(particle.x.toInt());
    _write(particle.y.toInt());
  });
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
  _write(character.x.toStringAsFixed(compilePositionDecimals));
  _write(character.y.toStringAsFixed(compilePositionDecimals));
  _write(character.id);
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
