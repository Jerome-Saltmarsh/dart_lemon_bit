import 'package:bleed_client/classes/InventoryItem.dart';
import 'package:bleed_client/connection.dart';
import 'package:bleed_client/enums/InventoryItemType.dart';
import 'package:bleed_client/enums/ServerResponse.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/functions/drawCanvas.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/keys.dart';
import 'package:bleed_client/utils.dart';

import 'enums/GameError.dart';
import 'enums/GameEventType.dart';
import 'enums/Weapons.dart';
import 'enums.dart';
import 'functions/onGameEvent.dart';
import 'instances/inventory.dart';
import 'state.dart';
import 'streams/onPlayerCreated.dart';

// state
final List _cache = [];
int _index = 0;

// properties
String get _text => event;

String get _currentCharacter => _text[_index];

// functions
void parseState() {
  _index = 0;
  event = event.trim();
  while (_index < _text.length) {
    ServerResponse serverResponse = _consumeServerResponse();
    switch (serverResponse) {
      case ServerResponse.Game_Id:
        _parseGameId();
        break;

      case ServerResponse.Tiles:
        _parseTiles();
        break;

      case ServerResponse.Player:
        _parsePlayer();
        break;

      case ServerResponse.Inventory:
        _parseInventory();
        break;

      case ServerResponse.Players:
        _parsePlayers();
        break;

      case ServerResponse.Error:
        GameError error = _consumeError();
        print(error);
        if(error == GameError.PlayerNotFound){
          clearState();
        }
        return;

      case ServerResponse.Bullets:
        _parseBullets();
        break;

      case ServerResponse.Npcs:
        _parseNpcs();
        break;

      case ServerResponse.Game_Events:
        _consumeEvents();
        break;

      case ServerResponse.Grenades:
        _parseGrenades();
        break;

      case ServerResponse.Pong:
        connected = true;
        connecting = false;
        break;

      case ServerResponse.Blocks:
        _parseBlocks();
        break;

      case ServerResponse.Player_Created:
        _parsePlayerCreated();
        break;

      case ServerResponse.Collectables:
        _parseCollectables();
        break;

      default:
        print("parser not implemented $serverResponse");
        return;
    }

    while (_index < _text.length) {
      if (_currentCharacter == " ") {
        _index++;
        continue;
      }
      if (_currentCharacter == ";") {
        _index++;
        break;
      }
      break;
    }
  }
}

void _parseGameId() {
  gameId = _consumeInt();
}

void _parseTiles() {
  print('parseTiles()');
  tilesX = _consumeInt();
  tilesY = _consumeInt();
  game.tiles.clear();
  for (int x = 0; x < tilesX; x++) {
    List<Tile> column = [];
    game.tiles.add(column);
    for (int y = 0; y < tilesY; y++) {
      column.add(Tile.values[_consumeInt()]);
    }
  }
}

void _parsePlayer() {
  game.playerX = _consumeDouble();
  game.playerY = _consumeDouble();
  game.playerWeapon = _consumeWeapon();
  playerHealth = _consumeDouble();
  playerMaxHealth = _consumeDouble();
  int stamina = _consumeInt();
  // TODO Logic does not belong here
  if (playerStamina != stamina) {
    playerStamina = stamina;
    redrawUI();
  }
  playerMaxStamina = _consumeInt();
  setHandgunRounds(_consumeInt());
  game.shotgunRounds = _consumeInt();
}

void _parseInventory() {
  inventory.rows = _consumeInt();
  inventory.columns = _consumeInt();
  int i = 0;
  while (!_simiColonConsumed()) {
    if (i < inventory.items.length) {
      inventory.items[i].type = _consumeInventoryItemType();
      inventory.items[i].row = _consumeInt();
      inventory.items[i].column = _consumeInt();
    } else {
      InventoryItemType type = _consumeInventoryItemType();
      int x = _consumeInt();
      int y = _consumeInt();
      inventory.items.add(InventoryItem(x, y, type));
    }
    i++;
  }

  while (inventory.items.length - i > 0) {
    inventory.items.removeLast();
  }
}

InventoryItemType _consumeInventoryItemType() {
  return InventoryItemType.values[_consumeInt()];
}

void _parseCollectables() {
  game.collectables.clear();
  while (!_simiColonConsumed()) {
    game.collectables.add(_consumeInt());
  }
}

void _parseGrenades() {
  game.grenades.clear();
  while (!_simiColonConsumed()) {
    game.grenades.add(_consumeDouble());
  }
}

void _parseBlocks() {
  blockHouses.clear();
  while (!_simiColonConsumed()) {
    blockHouses.add(createBlock(
      _consumeDouble(),
      _consumeDouble(),
      _consumeDouble(),
      _consumeDouble(),
      _consumeDouble(),
      _consumeDouble(),
      _consumeDouble(),
      _consumeDouble(),
    ));
  }
}

void _parsePlayerCreated() {
  int id = _consumeInt();
  String uuid = _consumeString();
  double x = _consumeDouble();
  double y = _consumeDouble();
  onPlayerCreated.add(OnPlayerCreated(uuid, id, x, y));
}

void _next() {
  _index++;
}

void _consumeSpace() {
  while (_currentCharacter == " ") {
    _next();
  }
}

int _consumeInt() {
  String string = _consumeString();
  int value = int.tryParse(string);
  if (value == null) {
    throw Exception("could not parse $string to int");
  }
  return value;
}

Weapon _consumeWeapon() {
  return Weapon.values[_consumeInt()];
}

int parseInt(String value) {
  return int.parse(value);
}

ServerResponse _consumeServerResponse() {
  int responseInt = _consumeInt();
  if (responseInt >= ServerResponse.values.length) {
    throw Exception('$responseInt is not a valid server response');
  }
  return ServerResponse.values[responseInt];
}

String _consumeString() {
  _consumeSpace();
  StringBuffer buffer = StringBuffer();
  while (_index < event.length && _currentCharacter != " ") {
    buffer.write(_currentCharacter);
    _index++;
  }
  _index++;
  return buffer.toString();
}

double _consumeDouble() {
  return double.parse(_consumeString());
}

bool _simiColonConsumed() {
  _consumeSpace();
  if (_currentCharacter == ";") {
    _index++;
    return true;
  }
  return false;
}

void _parsePlayers() {
  int index = 0;
  while (!_simiColonConsumed()) {
    if (index >= game.players.length) {
      game.players.add(_getUnusedMemory());
    }
    _consumePlayer(game.players[index]);
    index++;
  }
  while (index < game.players.length) {
    _cacheLast(game.players);
  }
}

GameError _consumeError() {
  return GameError.values[_consumeInt()];
}

void _consumeEvents() {
  int events = 0;
  while (!_simiColonConsumed()) {
    events++;
    int id = _consumeInt();
    GameEventType type = _consumeEventType();
    double x = _consumeDouble();
    double y = _consumeDouble();
    double xv = _consumeDouble();
    double yv = _consumeDouble();
    if (!gameEvents.containsKey(id)) {
      gameEvents[id] = true;
      onGameEvent(type, x, y, xv, yv);
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
    if (index >= game.bullets.length) {
      game.bullets.add(_getUnusedMemory());
    }
    _consumeBullet(game.bullets[index]);
    index++;
  }
  while (index < game.bullets.length) {
    _cacheLast(game.bullets);
  }
}

void _parseNpcs() {
  int index = 0;
  while (!_simiColonConsumed()) {
    if (index >= game.npcs.length) {
      game.npcs.add(_getUnusedMemory());
    }
    _consumeNpc(game.npcs[index]);
    index++;
  }
  while (index < game.npcs.length) {
    _cacheLast(game.npcs);
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
  memory[x] = _consumeDouble();
  memory[y] = _consumeDouble();
}

List _getUnusedMemory() {
  if (_cache.isEmpty) return [0, 0, 0.0, 0.0, 0, 0];
  return _cache.removeLast();
}
