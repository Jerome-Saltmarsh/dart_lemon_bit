import 'package:flutter_game_engine/bleed/connection.dart';
import 'package:flutter_game_engine/bleed/keys.dart';
import 'package:flutter_game_engine/bleed/state.dart';

import 'constants.dart';

final List _cache = [];

String get _text => event;
int _index = 0;

int get cacheSize => _cache.length;
String get currentCharacter => _text[_index];

void parseState() {
  _index = 0;
  while (_index < _text.length) {
    String term = _consumeString();
    if (term == "p:") {
      _parsePlayers();
    } else if (term == "id:") {
      _parsePlayerId();
    } else if (term == "b:") {
      _parseBullets();
    } else if (term == "n:") {
      _parseNpcs();
    } else if (term == "fms:"){
      _parseFrameMS();
    } else if (term == 'player-not-found') {
      print('server error: player-not-found');
      playerId = idNotConnected;
      if (respawnRequestSent) return;
      sendRequestSpawn();
      respawnRequestSent = true;
    } else if (term == 'invalid--uuid'){
      print("invalid uuid");
    }
  }
}


void _parseFrameMS(){
  serverFramesMS = _consumeInt();
  _consumeSemiColon();
}

void _parsePlayerId() {
  playerId = _consumeInt();
  playerUUID = _consumeString();
  _consumeSemiColon();
}

void _next(){
  _index++;
}

void _consumeSpace() {
  while (currentCharacter == " ") {
    _next();
  }
}

int _consumeInt() {
  return parseInt(_consumeString());
}

int parseInt(String value){
  return int.parse(value);
}

String _consumeString() {
  _consumeSpace();
  StringBuffer buffer = StringBuffer();
  while (currentCharacter != " ") {
    buffer.write(currentCharacter);
    _index++;
  }
  _index++;
  return buffer.toString();
}

double _consumeDouble() {
  return double.parse(_consumeString());
}

void _consumeSemiColon() {
  while (currentCharacter != ";") {
    _index++;
  }
  _index++;
}

bool _simiColonConsumed() {
  _consumeSpace();
  if (currentCharacter == ";") {
    _index++;
    return true;
  }
  return false;
}

void _parsePlayers() {
  int index = 0;
  while (!_simiColonConsumed()) {
    if (index >= players.length) {
      players.add(_getUnusedMemory());
    }
    _consumePlayer(players[index]);
    index++;
  }
  while (index < players.length) {
    _cacheLast(players);
  }
}

void _parseBullets() {
  int index = 0;
  while (!_simiColonConsumed()) {
    if (index >= bullets.length) {
      bullets.add(_getUnusedMemory());
    }
    _consumeBullet(bullets[index]);
    index++;
  }
  while (index < bullets.length) {
    _cacheLast(bullets);
  }
}

void _parseNpcs() {
  int index = 0;
  while (!_simiColonConsumed()) {
    if (index >= npcs.length) {
      npcs.add(_getUnusedMemory());
    }
    _consumeNpc(npcs[index]);
    index++;
  }
  while (index < npcs.length) {
    _cacheLast(npcs);
  }
}

void _cacheLast(List list) {
  _cache.add(list.removeLast());
}

void _consumePlayer(dynamic memory) {
  memory[state] = _consumeInt();
  memory[direction] = _consumeInt();
  memory[x] = _consumeDouble();
  memory[y] = _consumeDouble();
  memory[id] = _consumeInt();
}

void _consumeNpc(dynamic memory) {
  memory[state] = _consumeInt();
  memory[direction] = _consumeInt();
  memory[x] = _consumeDouble();
  memory[y] = _consumeDouble();
}

void _consumeBullet(dynamic memory) {
  memory[x] = _consumeDouble();
  memory[y] = _consumeDouble();
}

List _getUnusedMemory() {
  if (_cache.isEmpty) return [0, 0, 0.0, 0.0, 0];
  return _cache.removeLast();
}
