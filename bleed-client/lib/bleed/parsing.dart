import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter_game_engine/bleed/keys.dart';

GZipEncoder _gZipEncoder = GZipEncoder();
GZipDecoder _gZipDecoder = GZipDecoder();

String encode(dynamic data) {
  List<int> i = _gZipEncoder.encode(utf8.encode(jsonEncode(data)));
  if (i != null) {
    return base64.encode(i);
  }
  return "";
}

dynamic decode(String data) {
  return jsonDecode(
      (utf8.decode(_gZipDecoder.decodeBytes(base64.decode(data).toList()))));
}

/// [state, direction, positionX, positionY]
List<dynamic> unparseNpcs(List<dynamic> parsedCharacters){
  return parsedCharacters.map(unparseNpc).toList();
}

List<dynamic> unparsePlayers(List<dynamic> parsedCharacters){
  return parsedCharacters.map(unparsePlayer).toList();
}

List<dynamic> unparseBullets(List<dynamic> parseBullets){
  if(parseBullets.isEmpty) return [];
  return parseBullets.map(unparseBullet).toList();
}

dynamic unparseNpc(dynamic parsedCharacter){
  List<dynamic> attributes = parsedCharacter.split(" ");
  return [
    int.parse(attributes[state]),
    int.parse(attributes[direction]),
    double.parse(attributes[posX]),
    double.parse(attributes[posY]),
  ];
}

// 0 0 12.5 3.5 0
dynamic unparsePlayer(dynamic playerString){
  String p = playerString;
  int xLength = 1;
  while (playerString[4 + xLength] != " ") xLength++;
  int yLength = p.length - xLength - 7;
  int yStart = p.length - 3 - yLength;
  String x = p.substring(4, 4 + xLength);
  String y = p.substring(yStart, yStart + yLength + 1);
  String id = p.substring(p.length - 1, p.length);
  return [
    int.parse(playerString[0]),
    int.parse(playerString[2]),
    double.parse(x),
    double.parse(y),
    int.parse(id),
  ];
}

dynamic unparseBullet(dynamic bullet){
  List<String> b = bullet.split(" ");
  return [double.parse(b[0]), double.parse(b[1])];
}


