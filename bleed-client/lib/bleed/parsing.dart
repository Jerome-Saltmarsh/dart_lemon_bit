import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter_game_engine/bleed/state.dart';

GZipEncoder _gZipEncoder = GZipEncoder();
GZipDecoder _gZipDecoder = GZipDecoder();

String encode(dynamic data) {
  List<int> i = _gZipEncoder.encode(utf8.encode(jsonEncode(data)));
  if (i != null) {
    return base64.encode(i);
  }
  return "";
}

// dynamic decode(String data) {
//   return jsonDecode((utf8.decode(_gZipDecoder.decodeBytes(base64.decode(data).toList()))));
// }

String decompress(String data){
  return utf8.decode(_gZipDecoder.decodeBytes(base64.decode(data).toList()));
}

void parseState(String stateText){
  parsingText = stateText;
  parsingIndex = 0;
  while(parsingIndex < stateText.length){
    String term = consumeString();
    if (term == "p:"){
      parsePlayers();
    }
    else
    if (term == "id:"){
      parsePlayerId();
    }
  }
}

void parsePlayerId(){
  id = consumeInt();
  print('player id: $id');
}

String parseTerm(String text, String term){
  int start = text.indexOf(term);
  if(start == -1) return "";
  start += term.length;
  int end = start;
  while(text[end] != ";"){
    end++;
  }
  return text.substring(start, end);
}

String parsingText = "";
int parsingIndex = 0;

String get currentCharacter => parsingText[parsingIndex];

void incrementIndex(){
  parsingIndex++;
}

void consumeSpace(){
  while(currentCharacter == " "){
    incrementIndex();
  }
}

String consumeNextAvailableChar(){
  consumeSpace();
  String character = parsingText[parsingIndex];
  incrementIndex();
  return character;
}

int consumeInt(){
  return int.parse(consumeNextAvailableChar());
}

String consumeString(){
  consumeSpace();
  StringBuffer buffer = StringBuffer();
  while(currentCharacter != " "){
    buffer.write(currentCharacter);
    parsingIndex++;
  }
  incrementIndex();
  return buffer.toString();
}

double consumeDouble(){
  return double.parse(consumeString());
}

bool simiColonConsumed(){
  consumeSpace();
  if (currentCharacter == ";"){
    parsingIndex++;
    return true;
  }
  return false;
}

void parsePlayers(){
  players.clear();
  while(!simiColonConsumed()){
    parsePlayer();
  }
}

void parsePlayer(){
  return players.add([
    consumeInt(),
    consumeInt(),
    consumeDouble(),
    consumeDouble(),
    consumeInt(),
  ]);
}
//
// /// [state, direction, positionX, positionY]
// List<dynamic> unparseNpcs(List<dynamic> parsedCharacters){
//   return parsedCharacters.map(unparseNpc).toList();
// }

// List<dynamic> unparsePlayers(List<dynamic> parsedCharacters){
//   return parsedCharacters.map(unparsePlayer).toList();
// }
//
// List<dynamic> unparseBullets(List<dynamic> parseBullets){
//   if(parseBullets.isEmpty) return [];
//   return parseBullets.map(unparseBullet).toList();
// }

// dynamic unparseNpc(dynamic parsedCharacter){
//   List<dynamic> attributes = parsedCharacter.split(" ");
//   return [
//     int.parse(attributes[state]),
//     int.parse(attributes[direction]),
//     double.parse(attributes[posX]),
//     double.parse(attributes[posY]),
//   ];
// }

// // 0 0 12.5 3.5 0
// dynamic unparsePlayer(dynamic playerString){
//   String p = playerString;
//   int xLength = 1;
//   while (playerString[4 + xLength] != " ") xLength++;
//   int yLength = p.length - xLength - 7;
//   int yStart = p.length - 3 - yLength;
//   String x = p.substring(4, 4 + xLength);
//   String y = p.substring(yStart, yStart + yLength + 1);
//   String id = p.substring(p.length - 1, p.length);
//   return [
//     int.parse(playerString[0]),
//     int.parse(playerString[2]),
//     double.parse(x),
//     double.parse(y),
//     int.parse(id),
//   ];
// }

dynamic unparseBullet(dynamic bullet){
  List<String> b = bullet.split(" ");
  return [double.parse(b[0]), double.parse(b[1])];
}


