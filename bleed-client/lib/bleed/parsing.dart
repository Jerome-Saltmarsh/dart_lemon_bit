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
      parsePlayers2();
    } else if (term == "id:") {
      parsePlayerId();
    } else if (term == "b:") {
      parseBullets();
    } else if (term == "n:") {
      parseNpcs2();
    }
  }
}

void parseBullets() {
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

void parseNpcs() {
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

void parsePlayers2() {
  int index = 0;
  while (!simiColonConsumed()) {
    if (index >= players.length) {
      players.add(getAvailablePlayerArray());
    }
    parsePlayer2(players[index]);
    index++;
  }
  while (index < players.length) {
    _playerCache.add(players.removeLast());
  }
}

void parseNpcs2() {
  int index = 0;
  while (!simiColonConsumed()) {
    if (index >= npcs.length) {
      npcs.add(getAvailableNpcArray());
    }
    parseNpc2(npcs[index]);
    index++;
  }
  while (index < npcs.length) {
    _npcCache.add(npcs.removeLast());
  }
}

List getAvailablePlayerArray() {
  if (_playerCache.isEmpty) return [0, 0, 0.0, 0.0, 0];
  return _playerCache.removeLast();
}

List getAvailableNpcArray() {
  if (_npcCache.isEmpty) return [0, 0, 0.0, 0.0];
  return _npcCache.removeLast();
}

List _playerCache = [];
List _npcCache = [];

void parsePlayer() {
  players.add([
    consumeInt(),
    consumeInt(),
    consumeDouble(),
    consumeDouble(),
    consumeInt(),
  ]);
}

void parsePlayer2(List<dynamic> array) {
  array[0] = consumeInt();
  array[1] = consumeInt();
  array[2] = consumeDouble();
  array[3] = consumeDouble();
  array[4] = consumeInt();
}

void parseNpc2(List<dynamic> array) {
  array[0] = consumeInt();
  array[1] = consumeInt();
  array[2] = consumeDouble();
  array[3] = consumeDouble();
}

void parseBullet() {
  bullets.add([consumeDouble(), consumeDouble()]);
}
