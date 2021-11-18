import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/InventoryItem.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/PlayerEvents.dart';
import 'package:bleed_client/common/ServerResponse.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/core/init.dart';
import 'package:bleed_client/enums/InventoryItemType.dart';
import 'package:bleed_client/events.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/functions/emit/emitMyst.dart';
import 'package:bleed_client/functions/emitSmoke.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/network/functions/disconnect.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/network/state/connecting.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/dialogs.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/utils/list_util.dart';
import 'package:bleed_client/watches/compiledGame.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:lemon_engine/state/initialized.dart';
import 'package:neuro/instance.dart';

import 'classes/Score.dart';
import 'common/GameEventType.dart';
import 'common/GameState.dart';
import 'common/Tile.dart';
import 'common/Weapons.dart';
import 'common/classes/Vector2.dart';
import 'common/enums/EnvironmentObjectType.dart';
import 'common/version.dart';
import 'draw.dart';
import 'enums.dart';
import 'functions/onGameEvent.dart';
import 'state/inventory.dart';
import 'state.dart';

// state
int _index = 0;
// constants
const String _space = " ";
const String _semiColon = ";";
const String _comma = ",";
const String _1 = "1";

// enums
const List<ServerResponse> serverResponses = ServerResponse.values;
const List<Weapon> weapons = Weapon.values;
const List<GameEventType> gameEventTypes = GameEventType.values;

// properties
// String get _text => event;

String get _currentCharacter => compiledGame[_index];

// functions
void parseState() {
  _index = 0;
  compiledGame = compiledGame.trim();
  while (_index < compiledGame.length) {
    ServerResponse serverResponse = _consumeServerResponse();
    switch (serverResponse) {
      case ServerResponse.Tiles:
        _parseTiles();
        setBakeMapToAmbientLight();
        renderTiles(game.tiles);
        break;

      case ServerResponse.Paths:
        _parsePaths();
        break;

      case ServerResponse.Game_Time:
        timeInSeconds(_consumeInt());
        break;

      case ServerResponse.NpcsDebug:
        game.npcDebug.clear();
        while (!_simiColonConsumed()) {
          game.npcDebug.add(NpcDebug(
            x: _consumeDouble(),
            y: _consumeDouble(),
            targetX: _consumeDouble(),
            targetY: _consumeDouble(),
          ));
        }
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

      case ServerResponse.Version:
        state.serverVersion = _consumeInt();

        if (state.serverVersion == version) {
          joinGameCasual();
          // joinGameOpenWorld();
          break;
        }
        if (state.serverVersion < version) {
          showErrorDialog(
              "The server version ${state.serverVersion} you have connected to be older than your client $version. The game may not perform properly");
          break;
        }
        showDialogClientUpdateAvailable();
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
            if (compiledGame.length > 4) {
              String message = compiledGame.substring(4, compiledGame.length);
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
        _parseProjectiles();
        break;

      case ServerResponse.Npcs:
        _parseNpcs();
        break;

      case ServerResponse.Scene_Shade_Max:
        game.shadeMax.value = _consumeShade();
        break;

      case ServerResponse.Scene_Changed:
        print("ServerResponse.Scene_Changed");
        double x = _consumeDouble();
        double y = _consumeDouble();
        game.playerX = x;
        game.playerY = y;
        cameraCenter(x, y);

        Future.delayed(Duration(milliseconds: 150), () {
          cameraCenter(x, y);
        });
        for (Particle particle in game.particles) {
          particle.active = false;
        }
        break;

      case ServerResponse.EnvironmentObjects:
        game.particleEmitters.clear();
        _parseEnvironmentObjects();
        break;

      case ServerResponse.Zombies:
        _parseZombies();
        break;

      case ServerResponse.Game_Events:
        _consumeEvents();
        break;

      case ServerResponse.NpcMessage:
        String message = "";
        while (!_simiColonConsumed()) {
          message += _consumeString();
          message += " ";
        }
        player.message.value = message.trim();
        break;

      case ServerResponse.Crates:
        game.cratesTotal = 0;
        while (!_simiColonConsumed()) {
          game.crates[game.cratesTotal].x = _consumeDouble();
          game.crates[game.cratesTotal].y = _consumeDouble();
          game.cratesTotal++;
        }
        break;
      case ServerResponse.Grenades:
        _parseGrenades();
        break;

      case ServerResponse.Pong:
        connected = true;
        connecting = false;
        break;

      case ServerResponse.Game_Joined:
        _parseGameJoined();
        announce(GameJoined());
        break;

      case ServerResponse.Collectables:
        if (!gameStarted) return;
        _parseCollectables();
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
        game.totalItems = 0;
        while (!_simiColonConsumed()) {
          game.items[game.totalItems].type = _consumeItemType();
          game.items[game.totalItems].x = _consumeDouble();
          game.items[game.totalItems].y = _consumeDouble();
          game.totalItems++;
        }
        break;
      default:
        print("parser not implemented $serverResponse");
        return;
    }

    while (_index < compiledGame.length) {
      if (_currentCharacter == _space) {
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

void _parseEnvironmentObjects() {
  if (!initialized.value) {
    print(
        "parser.parseEnvironmentObjects() aborted because still initializing");
    return;
  }

  game.environmentObjects.clear();

  while (!_simiColonConsumed()) {
    double x = _consumeDouble();
    double y = _consumeDouble();
    EnvironmentObjectType type = _consumeEnvironmentObjectType();

    if (type == EnvironmentObjectType.SmokeEmitter) {
      game.particleEmitters
          .add(ParticleEmitter(x: x, y: y, rate: 20, emit: emitSmoke));
    }

    if (type == EnvironmentObjectType.MystEmitter) {
      game.particleEmitters
          .add(ParticleEmitter(x: x, y: y, rate: 20, emit: emitMyst));
    }

    Image image = environmentObjectImage[type];
    int index = environmentObjectIndex[type];
    double width = imageSpriteWidth[image];
    double height = imageSpriteHeight[image];

    Float32List dst = Float32List(4);
    dst[0] = 1;
    dst[1] = 0;
    dst[2] = x - (width * 0.5);
    dst[3] = y - (height * 0.6666);

    Float32List src = Float32List(4);
    src[0] = index * width; // left
    src[1] = 0; // top
    src[2] = index * width + width; // right
    src[3] = height; // bottom

    EnvironmentObject envObject = EnvironmentObject(
        x: x, y: y, type: type, dst: dst, src: src, image: image);

    envObject.tileRow = getRow(envObject.x, envObject.y);
    envObject.tileColumn = getColumn(envObject.x, envObject.y);

    if (type == EnvironmentObjectType.Bridge) {
      game.backgroundObjects.add(envObject);
      continue;
    }

    game.environmentObjects.add(envObject);
  }

  sortReversed(game.environmentObjects, environmentObjectY);
  applyEnvironmentObjectsToBakeMapping();
}

double environmentObjectY(EnvironmentObject environmentObject) {
  return environmentObject.y;
}

void _parseMetaFortress() {
  game.lives = _consumeInt();
  game.wave = _consumeInt();
  game.nextWave = _consumeInt();
}

void _parseMetaDeathMatch() {
  state.deathMatch.numberOfAlivePlayers = _consumeInt();
}

void _parsePaths() {
  paths.clear();
  while (!_simiColonConsumed()) {
    List<Vector2> path = [];
    paths.add(path);
    while (!_commaConsumed()) {
      path.add(_consumeVector2());
    }
  }
}

void _parseTiles() {
  game.totalRows = _consumeInt();
  game.totalColumns = _consumeInt();
  game.tiles.clear();
  for (int row = 0; row < game.totalRows; row++) {
    List<Tile> column = [];
    for (int columnIndex = 0; columnIndex < game.totalColumns; columnIndex++) {
      column.add(_consumeTile());
    }
    game.tiles.add(column);
  }
}

void _parsePlayer() {
  game.playerX = _consumeDouble();
  game.playerY = _consumeDouble();
  game.playerWeapon.value = _consumeWeapon();
  player.health.value = _consumeDouble();
  player.maxHealth = _consumeDouble();
  player.stamina = _consumeInt();
  player.staminaMax = _consumeInt();

  int grenades = _consumeInt();

  if (player.grenades != grenades) {
    player.grenades = grenades;
  }

  int meds = _consumeInt();
  if (player.meds != meds) {
    player.meds = meds;
  }
  game.playerLives = _consumeInt();
  player.equippedClips = _consumeInt();
  player.equippedRounds.value = _consumeInt();
  state.gameState = gameStates[_consumeInt()];
  player.points = _consumeInt();
  player.credits = _consumeInt();
  player.state.value = _consumeCharacterState();
  player.acquiredHandgun = _consumeBool();
  player.acquiredShotgun = _consumeBool();
  player.acquiredSniperRifle = _consumeBool();
  player.acquiredAssaultRifle = _consumeBool();
  player.tile = _consumeTile();
  player.roundsHandgun = _consumeInt();
  player.roundsShotgun = _consumeInt();
  player.roundsSniperRifle = _consumeInt();
  player.roundsAssaultRifle = _consumeInt();
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
  game.collectables.clear();
  while (!_simiColonConsumed()) {
    game.collectables.add(_consumeInt());
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

  rebuildScore();
}

void _parseGrenades() {
  game.grenades.clear();
  while (!_simiColonConsumed()) {
    game.grenades.add(_consumeDouble());
  }
}

void _parseGameJoined() {
  game.playerId = _consumeInt();
  game.playerUUID = _consumeString();
  game.playerX = _consumeDouble();
  game.playerY = _consumeDouble();
  game.gameId = _consumeInt();
  player.squad = _consumeInt();
  print(
      "ServerResponse.Game_Joined: playerId: ${game.playerId} gameId: ${game.gameId}");
}

EnvironmentObjectType _consumeEnvironmentObjectType() {
  return environmentObjectTypes[_consumeInt()];
}

void _next() {
  _index++;
}

void _consumeSpace() {
  while (_currentCharacter == _space) {
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

Direction _consumeDirection() {
  return directions[_consumeInt()];
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
  while (_index < compiledGame.length && _currentCharacter != _space) {
    buffer.write(_currentCharacter);
    _index++;
  }
  _index++;
  return buffer.toString();
}

double _consumeDouble() {
  return double.parse(_consumeString());
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
  game.totalHumans = 0;
  while (!_simiColonConsumed()) {
    _consumeHuman(game.humans[game.totalHumans]);
    game.totalHumans++;
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

void _parseProjectiles() {
  game.totalProjectiles = 0;
  while (!_simiColonConsumed()) {
    Projectile projectile = game.projectiles[game.totalProjectiles];
    projectile.x = _consumeDouble();
    projectile.y = _consumeDouble();
    projectile.type = _consumeProjectileType();
    projectile.direction = _consumeDirection();
    game.totalProjectiles++;
  }
}

ProjectileType _consumeProjectileType() {
  return projectileTypes[_consumeInt()];
}

void _parseZombies() {
  game.totalZombies = 0;
  while (!_simiColonConsumed()) {
    _consumeZombie(game.zombies[game.totalZombies]);
    game.totalZombies++;
  }
}

void _parseNpcs() {
  game.totalNpcs = 0;
  while (!_simiColonConsumed()) {
    _consumeInteractableNpc(game.interactableNpcs[game.totalNpcs]);
    game.totalNpcs++;
  }
}

void _consumeHuman(Character character) {
  character.state = _consumeCharacterState();
  character.direction = _consumeDirection();
  character.x = _consumeDouble();
  character.y = _consumeDouble();
  character.frame = _consumeInt();
  character.weapon = _consumeWeapon();
  character.squad = _consumeInt();
  character.name = _consumeString();

  StringBuffer textBuffer = StringBuffer();
  while (!_commaConsumed()) {
    textBuffer.write(_consumeString());
    textBuffer.write(_space);
  }
  character.text = textBuffer.toString().trim();
}

void _consumeZombie(Zombie zombie) {
  zombie.state = _consumeCharacterState();
  zombie.direction = _consumeDirection();
  zombie.x = _consumeDouble();
  zombie.y = _consumeDouble();
  zombie.frame = _consumeInt();
  zombie.scoreMultiplier = _consumeString();
}

void _consumeInteractableNpc(Character interactableNpc) {
  interactableNpc.state = _consumeCharacterState();
  interactableNpc.direction = _consumeDirection();
  interactableNpc.x = _consumeDouble();
  interactableNpc.y = _consumeDouble();
  interactableNpc.frame = _consumeInt();
  interactableNpc.name = _consumeString();
}

Shade _consumeShade() {
  return shades[_consumeInt()];
}
