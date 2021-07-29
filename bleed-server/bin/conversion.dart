import 'dart:convert';
import 'package:archive/archive.dart';

import 'classes.dart';
import 'state.dart';

GZipEncoder gZipEncoder = GZipEncoder();
GZipDecoder gZipDecoder = GZipDecoder();

String encode(dynamic data) {
  List<int>? i = gZipEncoder.encode(utf8.encode(jsonEncode(data)));
  if (i != null) {
    return base64.encode(i);
  }
  return "";
}

dynamic decode(String data) {
  return jsonDecode(
      (utf8.decode(gZipDecoder.decodeBytes(base64.decode(data).toList()))));
}



/**
    [
    [], zombies
    [], players
    [], bullets
    0, playerId
    1, accuracy
    2, weapon
    3, posX
    4, posY
    ]
 **/


List<String> parseBullets(){
  return bullets.map(parseBulletToString).toList();
}

/// [state, direction, positionX, positionY]
List<String> parseNpcs(){
  return npcs.map(parseNpcToString).toList();
}

List<String> parsePlayers(){
  return players.map(parsePlayerToString).toList();
}

String parseNpcToString(Npc npc){
  return "${npc.state.index} ${npc.direction.index} ${npc.x} ${npc.y}";
}

String parsePlayerToString(Character character){
  return "${character.state.index} ${character.direction.index} ${character.x} ${character.y} ${character.id}";
}

String parseBulletToString(Bullet bullet){
 return "${bullet.x} ${bullet.y}";
}