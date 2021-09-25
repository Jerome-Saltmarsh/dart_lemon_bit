import 'package:bleed_client/audio.dart';
import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/classes/InventoryItem.dart';
import 'package:bleed_client/classes/Lobby.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/PlayerEvents.dart';
import 'package:bleed_client/common/ServerResponse.dart';
import 'package:bleed_client/connection.dart';
import 'package:bleed_client/enums/InventoryItemType.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/functions/drawCanvas.dart';
import 'package:bleed_client/keys.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:neuro/instance.dart';

import 'classes/RenderState.dart';
import 'classes/Score.dart';
import 'classes/Vector2.dart';
import 'common/GameEventType.dart';
import 'common/GameState.dart';
import 'common/Tile.dart';
import 'common/Weapons.dart';
import 'draw.dart';
import 'enums.dart';
import 'functions/onGameEvent.dart';
import 'instances/inventory.dart';
import 'state.dart';

// state
int _index = 0;
// constants
const String _emptyString = " ";
const String _semiColon = ";";
const String _comma = ",";
const String _dash = "-";
const String _1 = "1";

// enums
const List<ServerResponse> serverResponses = ServerResponse.values;
const List<Weapon> weapons = Weapon.values;
const List<GameEventType> gameEventTypes = GameEventType.values;
const List<GameType> gameTypes = GameType.values;

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
      case ServerResponse.Tiles:
        _parseTiles();
        break;

      case ServerResponse.Paths:
        _parsePaths();
        break;

      case ServerResponse.MetaFortress:
        _parseMetaFortress();
        break;

      case ServerResponse.MetaDeathMatch:
        _parseMetaDeathMatch();
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

        switch (error) {
          case GameError.GameNotFound:
            clearState();
            disconnect();
            showErrorDialog("You were disconnected from the game");
            return;
          case GameError.InvalidArguments:
            if (event.length > 4) {
              String message = event.substring(4, event.length);
              print('Invalid Arguments: $message');
            }
            return;
        }
        if (error == GameError.PlayerNotFound) {
          clearState();
          disconnect();
          showErrorDialogPlayerNotFound();
        }
        if (error == GameError.LobbyNotFound) {
          print("Server Error: Lobby not found");
          state.lobby = null;
          showErrorDialog("Lobby not found");
        }
        return;

      case ServerResponse.Bullets:
        _parseBullets();
        break;

      case ServerResponse.Npcs:
        try {
          _parseNpcs();
        } catch (error) {
          print(error);
        }
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

      case ServerResponse.Game_Joined:
        _parseGameJoined();
        announce(GameJoined());
        break;

      case ServerResponse.GameOver:
        gameOver = true;
        print('game over');
        break;

      case ServerResponse.Collectables:
        if (!gameStarted) return;
        _parseCollectables();
        break;

      case ServerResponse.Lobby_Joined:
        print('ServerResponse.Lobby_Joined');
        state.lobby = Lobby();
        state.lobby.uuid = _consumeString();
        state.lobby.playerUuid = _consumeString();
        announce(LobbyJoined());
        break;

      case ServerResponse.Lobby_List:
        state.lobbies.clear();
        while (!_simiColonConsumed()) {
          Lobby lobby = _consumeLobby();
          state.lobbies.add(lobby);
        }
        break;

      case ServerResponse.Lobby_Update:
        if (state.lobby == null) return;
        state.lobby.maxPlayers = _consumeInt();
        state.lobby.playersJoined = _consumeInt();
        state.lobby.uuid = _consumeString();
        state.lobby.name = _consumeString();
        state.lobbyGameUuid = _consumeString();
        if (state.lobbyGameUuid == _dash) continue;
        state.lobby = null;
        sendRequestJoinGame(state.lobbyGameUuid);
        break;

      case ServerResponse.Player_Events:
        _parsePlayerEvents();
        return;

      case ServerResponse.Player:
        _parsePlayer();
        break;

      case ServerResponse.Score:
        _parseScore();
        break;

      case ServerResponse.Items:
        compiledGame.totalItems = 0;
        while (!_simiColonConsumed()) {
          compiledGame.items[compiledGame.totalItems].type = _consumeItemType();
          compiledGame.items[compiledGame.totalItems].x = _consumeDouble();
          compiledGame.items[compiledGame.totalItems].y = _consumeDouble();
          compiledGame.totalItems++;
        }
        break;
      default:
        print("parser not implemented $serverResponse");
        return;
    }

    while (_index < _text.length) {
      if (_currentCharacter == _emptyString) {
        _index++;
        continue;
      }
      if (_currentCharacter == _semiColon) {
        _index++;
        break;
      }
      break;
    }
  }
}

void _parseMetaFortress() {
  compiledGame.lives = _consumeInt();
  compiledGame.wave = _consumeInt();
  compiledGame.nextWave = _consumeInt();
}

void _parseMetaDeathMatch() {
  state.deathMatch.numberOfAlivePlayers = _consumeInt();
}

void _parsePaths() {
  render.paths.clear();
  while (!_simiColonConsumed()) {
    List<Vector2> path = [];
    render.paths.add(path);
    while (!_commaConsumed()) {
      path.add(_consumeVector2());
    }
  }
}

void _parseTiles() {
  int tilesX = _consumeInt();
  int tilesY = _consumeInt();
  compiledGame.tiles.clear();
  for (int x = 0; x < tilesX; x++) {
    List<Tile> column = [];
    compiledGame.tiles.add(column);
    for (int y = 0; y < tilesY; y++) {
      column.add(Tile.values[_consumeInt()]);
    }
  }
  // TODO Bad Import
  renderTiles(compiledGame.tiles);
}

void _parsePlayer() {
  compiledGame.playerX = _consumeDouble();
  compiledGame.playerY = _consumeDouble();
  compiledGame.playerWeapon = _consumeWeapon();
  player.health = _consumeDouble();
  player.maxHealth = _consumeDouble();
  player.stamina = _consumeInt();
  player.staminaMax = _consumeInt();
  player.grenades = _consumeInt();
  player.meds = _consumeInt();
  compiledGame.playerLives = _consumeInt();
  player.equippedClips = _consumeInt();
  player.equippedRounds = _consumeInt();
  state.gameState = gameStates[_consumeInt()];
  player.points = _consumeInt();
  player.credits = _consumeInt();

  CharacterState charState = _consumeCharacterState();
  if (charState != player.state) {
    CharacterState previous = player.state;
    player.state = charState;
    onPlayerStateChanged(previous, charState);
  }

  player.acquiredHandgun = _consumeBool();
  player.acquiredShotgun = _consumeBool();
  player.acquiredSniperRifle = _consumeBool();
  player.acquiredAssaultRifle = _consumeBool();

  Tile tile = _consumeTile();

  if (player.tile != tile) {
    Tile previousTile = player.tile;
    player.tile = tile;
    onPlayerTileChanged(previousTile, tile);
  }
  player.clipsHandgun = _consumeInt();
  player.clipsShotgun = _consumeInt();
  player.clipsSniperRifle = _consumeInt();
  player.clipsAssaultRifle = _consumeInt();
}

void _parsePlayerEvents() {
  while (!_simiColonConsumed()) {
    PlayerEventType playerEvent = playerEventTypes[_consumeInt()];
    int value = _consumeInt();
    switch (playerEvent) {
      case PlayerEventType.Acquired_Handgun:
        playAudioAcquireItem(playerX, playerY);
        break;
    }
  }
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
  // todo this is really expensive
  compiledGame.collectables.clear();
  while (!_simiColonConsumed()) {
    compiledGame.collectables.add(_consumeInt());
  }
}

void _parseScore() {
  // TODO Optimize
  state.score.clear();
  while (!_simiColonConsumed()) {
    Score score = Score();
    score.playerName = _consumeString();
    score.points = _consumeInt();
    score.record = _consumeInt();
    state.score.add(score);
  }

  state.score.sort((Score a, Score b) {
    if (a.points > b.points) return -1;
    return 1;
  });
}

void _parseGrenades() {
  compiledGame.grenades.clear();
  while (!_simiColonConsumed()) {
    compiledGame.grenades.add(_consumeDouble());
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

void _parseGameJoined() {
  state.compiledGame.playerId = _consumeInt();
  state.compiledGame.playerUUID = _consumeString();
  state.compiledGame.playerX = _consumeDouble();
  state.compiledGame.playerY = _consumeDouble();
  state.compiledGame.gameId = _consumeInt();
  state.compiledGame.gameType = _consumeGameType();
  state.player.squad = _consumeInt();
  state.lobby = null;
  print(
      "ServerResponse.Game_Joined: playerId: ${state.compiledGame.playerId} gameId: ${state.compiledGame.gameId}");
}

GameType _consumeGameType() {
  int value = _consumeInt();
  if (value >= gameTypes.length) {
    throw Exception(
        'error - parse._consumeGameType() : $value is not a valid game type');
  }
  return gameTypes[value];
}

void _next() {
  _index++;
}

void _consumeSpace() {
  while (_currentCharacter == _emptyString) {
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

bool _consumeBool() {
  return _consumeString() == _1 ? true : false;
}

Weapon _consumeWeapon() {
  return weapons[_consumeInt()];
}

CharacterState _consumeCharacterState() {
  return characterStates[_consumeInt()];
}

Tile _consumeTile() {
  return tiles[_consumeInt()];
}

int parseInt(String value) {
  return int.parse(value);
}

ServerResponse _consumeServerResponse() {
  int responseInt = _consumeInt();
  if (responseInt >= ServerResponse.values.length) {
    throw Exception('$responseInt is not a valid server response');
  }
  return serverResponses[responseInt];
}

String _consumeString() {
  _consumeSpace();
  StringBuffer buffer = StringBuffer();
  while (_index < event.length && _currentCharacter != _emptyString) {
    buffer.write(_currentCharacter);
    _index++;
  }
  _index++;
  return buffer.toString();
}

double _consumeDouble() {
  return double.parse(_consumeString());
}

Lobby _consumeLobby() {
  int maxPlayers = _consumeInt();
  int playersJoined = _consumeInt();
  String lobbyUuid = _consumeString();
  String lobbyName = _consumeString();
  String gameUuid = _consumeString();

  return Lobby()
    ..maxPlayers = maxPlayers
    ..playersJoined = playersJoined
    ..uuid = lobbyUuid
    ..name = lobbyName
    ..gameUuid = gameUuid;
}

Vector2 _consumeVector2() {
  return Vector2(_consumeDouble(), _consumeDouble());
}

bool _simiColonConsumed() {
  _consumeSpace();
  if (_currentCharacter == _semiColon) {
    _index++;
    return true;
  }
  return false;
}

bool _commaConsumed() {
  _consumeSpace();
  if (_currentCharacter == _comma) {
    _index++;
    return true;
  }
  return false;
}

void _parsePlayers() {
  compiledGame.totalPlayers = 0;
  while (!_simiColonConsumed()) {
    _consumePlayer(compiledGame.players[compiledGame.totalPlayers]);
    compiledGame.totalPlayers++;
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
    gameEvents.clear(); // free up memory
  }
}

GameEventType _consumeEventType() {
  return gameEventTypes[_consumeInt()];
}

ItemType _consumeItemType() {
  return itemTypes[_consumeInt()];
}

void _parseBullets() {
  compiledGame.totalBullets = 0;
  int index = 0;
  while (!_simiColonConsumed()) {
    compiledGame.bullets[index] = _consumeDouble();
    index++;
    compiledGame.bullets[index] = _consumeDouble();
    index++;
  }
  compiledGame.totalBullets = index ~/ 2;
}

void _parseNpcs() {
  compiledGame.totalNpcs = 0;
  while (!_simiColonConsumed()) {
    _consumeNpc(compiledGame.npcs[compiledGame.totalNpcs]);
    compiledGame.totalNpcs++;
  }
}

void _consumePlayer(dynamic memory) {
  memory[stateIndex] = _consumeInt(); // TODO optimization remove int parse
  memory[direction] = _consumeInt(); // TODO optimization remove int parse
  memory[x] = _consumeDouble();
  memory[y] = _consumeDouble();
  memory[frameCount] = _consumeInt();
  memory[weapon] = _consumeWeapon(); // TODO optimization remove int parse
  memory[squad] = _consumeInt();
  try {
    memory[indexName] = _consumeString();
  } catch (error) {
    print(error);
  }
}

void _consumeNpc(dynamic npcMemory) {
  npcMemory[stateIndex] = _consumeInt(); // TODO optimization remove int parse
  npcMemory[direction] = _consumeInt(); // TODO optimization remove int parse
  npcMemory[x] = _consumeDouble();
  npcMemory[y] = _consumeDouble();
  npcMemory[frameCount] = _consumeInt();
  npcMemory[indexPointMultiplier] = _consumeString();
}
