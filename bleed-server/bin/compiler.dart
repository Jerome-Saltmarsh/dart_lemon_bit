import 'dart:convert';
import 'package:archive/archive.dart';

import 'classes.dart';
import 'state.dart';

GZipEncoder gZipEncoder = GZipEncoder();
GZipDecoder gZipDecoder = GZipDecoder();

String compress(String data){
  List<int>? i = gZipEncoder.encode(utf8.encode(data));
  if (i != null) {
    return base64.encode(i);
  }
  return "";
}

String compileState(){
  StringBuffer buffer = StringBuffer();
  compilePlayers(buffer);
  compileBullets(buffer);
  return buffer.toString();
}

void compilePlayers(StringBuffer buffer){
  buffer.write("p: ");
  for(Character character in players){
    compilePlayer(buffer, character);
    buffer.write(" ");
  }
  buffer.write(";");
}

void compileBullets(StringBuffer buffer){
  buffer.write("b: ");
  for (Bullet bullet in bullets){
    buffer.write("${bullet.x} ${bullet.y} ");
  }
  buffer.write(";");
}

String compileNpcToString(Npc npc){
  return "${npc.state.index} ${npc.direction.index} ${npc.x} ${npc.y}";
}

void compilePlayer(StringBuffer buffer, Character character){
  buffer.write("${character.state.index} ${character.direction.index} ${character.x} ${character.y} ${character.id}");
}

String compileBulletToString(Bullet bullet){
 return "${bullet.x} ${bullet.y}";
}
