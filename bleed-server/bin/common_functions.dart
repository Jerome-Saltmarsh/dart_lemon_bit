import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:archive/archive.dart';

import 'common.dart';
import 'state.dart';
import 'utils.dart';

const double eight = pi / 8.0;
const double quarter = pi / 4.0;

int convertAngleToDirection(double angle) {
  if (angle < eight) {
    return directionUp;
  }
  if (angle < eight + (quarter * 1)) {
    return directionUpRight;
  }
  if (angle < eight + (quarter * 2)) {
    return directionRight;
  }
  if (angle < eight + (quarter * 3)) {
    return directionDownRight;
  }
  if (angle < eight + (quarter * 4)) {
    return directionDown;
  }
  if (angle < eight + (quarter * 5)) {
    return directionDownLeft;
  }
  if (angle < eight + (quarter * 6)) {
    return directionLeft;
  }
  if (angle < eight + (quarter * 7)) {
    return directionUpLeft;
  }
  return directionUp;
}

GZipEncoder gZipEncoder = GZipEncoder();
GZipDecoder gZipDecoder = GZipDecoder();

String encode(dynamic data) {
  // List<int>? i = gZipEncoder.encode(utf8.encode(jsonEncode(data).replaceAll(" ", "")));
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


/// [state, direction, positionX, positionY]
String parseCharacterToString(dynamic character){
  return "${character[indexState]} ${character[indexDirection]} ${character[indexPosX]} ${character[indexPosY]}";
}

List<String> parseCharacters(){
  return characters.map(parseCharacterToString).toList();
}

List<dynamic> unparseCharacters(List<String> parsedCharacters){
  return parsedCharacters.map(unparseCharacter).toList();
}

dynamic unparseCharacter(String parsedCharacter){
  List<String> attributes = parsedCharacter.split(" ");
  return [
    int.parse(attributes[0]),
    int.parse(attributes[1]),
    double.parse(attributes[2]),
    double.parse(attributes[3]),
    double.parse(attributes[4]),
  ];
}