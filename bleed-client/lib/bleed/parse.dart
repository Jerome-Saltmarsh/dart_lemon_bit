import 'package:flutter_game_engine/bleed/events.dart';
import 'package:flutter_game_engine/bleed/keys.dart';
import 'package:flutter_game_engine/bleed/state.dart';
import 'package:flutter_game_engine/bleed/utils.dart';

import 'constants.dart';
import 'enums.dart';

final List _cache = [];

String get _text => event;
int _index = 0;

int get cacheSize => _cache.length;

String get currentCharacter => _text[_index];

void parseState() {
  _index = 0;
  event = event.trim();
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
    } else if (term == "fms:") {
      _parseFrameMS();
    } else if (term == 'player-not-found') {
      _consumePlayerNotFound();
    } else if (term == 'invalid--uuid') {
      _consumeInvalidUUID();
    } else if (term == 'player:') {
      _parsePlayer();
    } else if (term == 'tiles:') {
      _parseTiles();
    } else if (term == "pass:") {
      _consumePass();
    } else if (term == "f:") {
      _consumeFrame();
    } else if (term == "events:") {
      _consumeEvents();
    } else if (term == "blood:") {
      _consumeBlood();
    } else if (term == "particles") {
      _consumeParticles();
    } else {
      throw Exception("term not found: $term");
    }
  }
}

void _consumeBlood(){
  blood.clear();
  while (!_simiColonConsumed()) {
    blood.add(_consumeDouble());
  }
}

void _consumeParticles(){
  particles.clear();
  while (!_simiColonConsumed()) {
    particles.add(_consumeDouble());
  }
}

void _consumePlayerNotFound() {
  playerId = idNotConnected;
  _consumeSemiColon();
}

void _consumeInvalidUUID() {
  playerId = idNotConnected;
  playerUUID = "";
  _consumeSemiColon();
}

void _consumePass() {
  pass = _consumeInt();
  _consumeSemiColon();
}

void _consumeFrame() {
  serverFrame = _consumeInt();
  _consumeSemiColon();
}

void _parseTiles() {
  print('parseTiles()');
  tilesX = _consumeInt();
  tilesY = _consumeInt();
  tiles.clear();
  for (int x = 0; x < tilesX; x++) {
    List<Tile> column = [];
    tiles.add(column);
    for (int y = 0; y < tilesY; y++) {
      column.add(Tile.values[_consumeInt()]);
    }
  }
  _consumeSemiColon();
}

void _parsePlayer() {
  playerHealth = _consumeDouble();
  playerMaxHealth = _consumeDouble();
  _consumeSemiColon();
}

void _parseFrameMS() {
  serverFramesMS = _consumeInt();
  _consumeSemiColon();
}

void _parsePlayerId() {
  playerId = _consumeInt();
  playerUUID = _consumeString();
  int x = _consumeInt();
  int y = _consumeInt();
  // HACK: doesn't belong here
  cameraCenter(x.toDouble(), y.toDouble());
}

void _next() {
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

Weapon _consumeWeapon(){
  return Weapon.values[_consumeInt()];
}

int parseInt(String value) {
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

  player = getPlayerCharacter();
}

void _consumeEvents() {
  int events = 0;
  while (!_simiColonConsumed()) {
    events++;
    int id = _consumeInt();
    GameEventType type = _consumeEventType();
    int x = _consumeInt();
    int y = _consumeInt();
    if (!gameEvents.containsKey(id)) {
      gameEvents[id] = true;
      onGameEvent(type, x, y);
    }
  }
  if (events == 0) {
    gameEvents.clear(); // free up some memory
  }
}

GameEventType _consumeEventType() {
  return GameEventType.values[_consumeInt()];
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
  memory[weapon] = _consumeWeapon();
}

void _consumeNpc(dynamic memory) {
  memory[state] = _consumeInt();
  memory[direction] = _consumeInt();
  memory[x] = _consumeDouble();
  memory[y] = _consumeDouble();
}

void _consumeBullet(dynamic memory) {
  memory[id] = _consumeInt();
  memory[x] = _consumeDouble();
  memory[y] = _consumeDouble();
}

List _getUnusedMemory() {
  if (_cache.isEmpty) return [0, 0, 0.0, 0.0, 0, 0];
  return _cache.removeLast();
}
