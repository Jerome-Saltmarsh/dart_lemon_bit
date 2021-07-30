import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter_game_engine/bleed/state.dart';

GZipDecoder _gZipDecoder = GZipDecoder();

String decompress(String data) {
  return utf8.decode(_gZipDecoder.decodeBytes(base64.decode(data).toList()));
}

void parseState(String stateText) {
  parsingText = stateText;
  parsingIndex = 0;
  while (parsingIndex < stateText.length) {
    String term = consumeString();
    if (term == "p:") {
      parsePlayers();
    } else if (term == "id:") {
      parsePlayerId();
    } else if (term == "b:") {
      parseBullets();
    } else if (term == "n:") {
      parseNpcs();
    }
  }
}

void parseBullets(){
  bullets.clear();
  while (!simiColonConsumed()) {
    parseBullet();
  }
}

void parsePlayerId() {
  id = consumeInt();
  print('player id: $id');
}

String parseTerm(String text, String term) {
  int start = text.indexOf(term);
  if (start == -1) return "";
  start += term.length;
  int end = start;
  while (text[end] != ";") {
    end++;
  }
  return text.substring(start, end);
}

String parsingText = "";
int parsingIndex = 0;

String get currentCharacter => parsingText[parsingIndex];

void incrementIndex() {
  parsingIndex++;
}

void consumeSpace() {
  while (currentCharacter == " ") {
    incrementIndex();
  }
}

String consumeNextAvailableChar() {
  consumeSpace();
  String character = parsingText[parsingIndex];
  incrementIndex();
  return character;
}

int consumeInt() {
  return int.parse(consumeNextAvailableChar());
}

String consumeString() {
  consumeSpace();
  StringBuffer buffer = StringBuffer();
  while (currentCharacter != " ") {
    buffer.write(currentCharacter);
    parsingIndex++;
  }
  incrementIndex();
  return buffer.toString();
}

double consumeDouble() {
  return double.parse(consumeString());
}

bool simiColonConsumed() {
  consumeSpace();
  if (currentCharacter == ";") {
    parsingIndex++;
    return true;
  }
  return false;
}

void parseNpcs(){
  npcs.clear();
  while (!simiColonConsumed()) {
    parseNpc();
  }
}

void parseNpc() {
  npcs.add([
    consumeInt(),
    consumeInt(),
    consumeDouble(),
    consumeDouble(),
  ]);
}


void parsePlayers() {
  players.clear();
  while (!simiColonConsumed()) {
    parsePlayer();
  }
}

void parsePlayer() {
  players.add([
    consumeInt(),
    consumeInt(),
    consumeDouble(),
    consumeDouble(),
    consumeInt(),
  ]);
}

void parseBullet(){
  bullets.add([
    consumeDouble(),
    consumeDouble()
  ]);
}
