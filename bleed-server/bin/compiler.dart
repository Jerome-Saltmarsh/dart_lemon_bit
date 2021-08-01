import 'classes.dart';
import 'state.dart';

void compileState(){
  buffer.clear();
  _compilePlayers();
  _compileNpcs();
  // _compileBullets();
  _compileFPS();
  compiledState = buffer.toString();
}

void _compileFPS(){
   buffer.write("fms: ${ frameDuration.inMilliseconds } ;");
}

void _compilePlayers(){
  _write("p:");
  players.forEach(_compileCharacter);
  _end();
}

void _compileNpcs(){
  _write("n:");
  npcs.forEach(_compileNpc);
  _end();
}

void _compileBullets(){
  _write("b:");
  bullets.forEach(_compileBullet);
  _end();
}

void _compileBullet(Bullet bullet){
  _write(bullet.x);
  _write(bullet.y);
}

void _compileCharacter(Character character){
  _write(character.state.index);
  _write(character.direction.index);
  _write(character.x);
  _write(character.y);
  _write(character.id);
}

void _compileNpc(Npc npc){
  _write(npc.state.index);
  _write(npc.direction.index);
  _write(npc.x);
  _write(npc.y);
}

void _write(dynamic value){
  buffer.write(value);
  buffer.write(" ");
}

void _end(){
  buffer.write("; ");
}
