import 'classes.dart';
import 'state.dart';

void compileState(){
  buffer.clear();
  _compilePlayers();
  _compileNpcs();
  _compileBullets();
  _compileFPS();
  compiledState = buffer.toString();
}

void _compileFPS(){
   buffer.write("fms: ${ frameDuration.inMilliseconds } ;");
}

void _compilePlayers(){
  buffer.write("p: ");
  for(Character character in players){
    _compileCharacter(character);
  }
  _end();
}

void _compileNpcs(){
  buffer.write("n: ");
  for(Npc npc in npcs){
    _compileNpc(npc);
  }
  _end();
}

void _compileBullets(){
  buffer.write("b: ");
  for (Bullet bullet in bullets){
    _write(bullet.x);
    _write(bullet.y);
  }
  _end();
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
