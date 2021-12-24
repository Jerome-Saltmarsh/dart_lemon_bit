import 'dart:typed_data';
import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Ability.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Weapon.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/PlayerEvent.dart';
import 'package:bleed_client/common/ServerResponse.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/functions/emit/emitMyst.dart';
import 'package:bleed_client/functions/emitSmoke.dart';
import 'package:bleed_client/getters/getTileAt.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/parser/parseCubePlayers.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/utils/list_util.dart';
import 'package:bleed_client/watches/compiledGame.dart';
import 'package:bleed_client/watches/time.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/cursor.dart';

import 'common/GameEventType.dart';
import 'common/PlayerEvent.dart';
import 'common/Tile.dart';
import 'common/WeaponType.dart';
import 'common/classes/Vector2.dart';
import 'common/enums/ObjectType.dart';
import 'functions/onGameEvent.dart';
import 'network.dart';
import 'render/functions/mapTilesToSrcAndDst.dart';
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
        mapTilesToSrcAndDst(game.tiles);
        break;

      case ServerResponse.Paths:
        _parsePaths();
        break;

      case ServerResponse.Game_Time:
        timeInSeconds(consumeInt());
        break;

      case ServerResponse.NpcsDebug:
        game.npcDebug.clear();
        while (!_simiColonConsumed()) {
          game.npcDebug.add(NpcDebug(
            x: consumeDouble(),
            y: consumeDouble(),
            targetX: consumeDouble(),
            targetY: consumeDouble(),
          ));
        }
        break;

      case ServerResponse.Waiting_For_More_Players:
        game.numberOfPlayersNeeded.value = consumeInt();
        break;

      case ServerResponse.Player_Attack_Target:
        game.player.attackTarget.x = consumeDouble();
        game.player.attackTarget.y = consumeDouble();

        if (game.player.attackTarget.x != 0 &&
            game.player.attackTarget.y != 0) {
          cursorType.value = CursorType.Click;
        } else {
          cursorType.value = CursorType.Basic;
        }
        break;

      case ServerResponse.Player_Abilities:
        _consumeAbility(game.player.ability1);
        _consumeAbility(game.player.ability2);
        _consumeAbility(game.player.ability3);
        _consumeAbility(game.player.ability4);
        break;

      case ServerResponse.Team_Lives_Remaining:
        game.teamLivesWest.value = consumeInt();
        game.teamLivesEast.value = consumeInt();
        break;

      case ServerResponse.Weapons_Dirty:
        hud.skillTreeVisible.value = !hud.skillTreeVisible.value;
        hud.skillTreeVisible.value = !hud.skillTreeVisible.value;
        break;

      case ServerResponse.Weapons:
        game.player.weapons.clear();
        int length = _consumeIntUnsafe();
        for (int i = 0; i < length; i++) {
          game.player.weapons.add(_consumeWeapon());
        }
        break;

      case ServerResponse.Players:
        _parsePlayers();
        break;

      case ServerResponse.Version:
        // sendRequestJoinGame();
        break;

      case ServerResponse.Error:
        GameError error = _consumeError();
        print(error);

        switch (error) {
          case GameError.GameNotFound:
            clearState();
            disconnect();
            return;
          case GameError.InvalidArguments:
            if (compiledGame.length > 4) {
              String message = compiledGame.substring(4, compiledGame.length);
              print('Invalid Arguments: $message');
            }
            return;
          default:
            break;
        }
        if (error == GameError.PlayerNotFound) {
          clearState();
          disconnect();
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
        double x = consumeDouble();
        double y = consumeDouble();
        game.player.x = x;
        game.player.y = y;
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
        game.player.message.value = message.trim();
        break;

      case ServerResponse.Crates:
        game.cratesTotal = 0;
        while (!_simiColonConsumed()) {
          game.crates[game.cratesTotal].x = consumeDouble();
          game.crates[game.cratesTotal].y = consumeDouble();
          game.cratesTotal++;
        }
        break;
      case ServerResponse.Grenades:
        _parseGrenades();
        break;

      case ServerResponse.Pong:
        // connected = true;
        // connecting = false;
        break;

      case ServerResponse.Game_Joined:
        _parseGameJoined();
        break;

      case ServerResponse.Game_Type:
        // game.type.value = gameTypes[_consumeInt()];
        var type = gameTypes[consumeInt()];
        break;

      case ServerResponse.Game_Status:
        game.status.value = gameStatuses[consumeInt()];
        break;

      case ServerResponse.Cube_Joined:
        game.player.uuid.value = _consumeString();
        break;

      case ServerResponse.Cube_Players:
        parseCubePlayers();
        redrawCanvas();
        break;

      case ServerResponse.Lobby:
        game.lobby.playerCount.value = consumeInt();
        game.lobby.players.clear();
        for (int i = 0; i < game.lobby.playerCount.value; i++) {
          String name = _consumeString();
          int team = consumeInt();
          game.lobby.add(team: team, name: name);
        }
        break;

      case ServerResponse.Collectables:
        if (game.id < 0) return;
        _parseCollectables();
        break;

      case ServerResponse.Player_Events:
        _parsePlayerEvents();
        return;

      case ServerResponse.Player:
        _parsePlayer();
        break;

      case ServerResponse.Items:
        game.totalItems = consumeInt();
        for (int i = 0; i < game.totalItems; i++) {
          Item item = game.items[i];
          item.type = _consumeItemType();
          item.x = consumeDouble();
          item.y = consumeDouble();
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
  print("parseEnvironmentObjects()");
  game.environmentObjects.clear();
  game.torches.clear();

  while (!_simiColonConsumed()) {
    double x = consumeDouble();
    double y = consumeDouble();
    double radius = consumeDouble();
    ObjectType type = _consumeEnvironmentObjectType();

    switch (type) {
      case ObjectType.SmokeEmitter:
        addParticleEmitter(
            ParticleEmitter(x: x, y: y, rate: 20, emit: emitSmoke));
        break;
      case ObjectType.MystEmitter:
        addParticleEmitter(
            ParticleEmitter(x: x, y: y, rate: 20, emit: emitMyst));
        break;
      case ObjectType.Torch:
        // addParticleEmitter(ParticleEmitter(x: x, y: y - 40, rate: 75, emit: emitPixel));
        break;
      default:
        // ignore
        break;
    }

    double width = environmentObjectWidth[type]!;
    double height = environmentObjectHeight[type]!;

    Float32List dst = Float32List(4);
    dst[0] = 1;
    dst[1] = 0;
    dst[2] = x - (width * 0.5);
    dst[3] = y - (height * 0.6666);

    EnvironmentObject env =
        EnvironmentObject(x: x, y: y, type: type, dst: dst, radius: radius);

    if (type == ObjectType.Torch) {
      game.torches.add(env);
    }

    env.row = getRow(env.x, env.y);
    env.column = getColumn(env.x, env.y);
    game.environmentObjects.add(env);
  }

  // * on environmentObjects changed
  sortReversed(game.environmentObjects, environmentObjectY);
  applyEnvironmentObjectsToBakeMapping();
}

void addParticleEmitter(ParticleEmitter value) {
  game.particleEmitters.add(value);
}

double environmentObjectY(EnvironmentObject environmentObject) {
  return environmentObject.y;
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
  game.totalRows = consumeInt();
  game.totalColumns = consumeInt();
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
  game.player.x = consumeDouble();
  game.player.y = consumeDouble();
  game.player.health.value = consumeDouble();
  game.player.maxHealth = consumeDouble();
  game.player.state.value = _consumeCharacterState();
  game.player.tile = _consumeTile();
  game.player.experience.value = consumeInt();
  game.player.level.value = consumeInt();
  game.player.skillPoints.value = consumeInt();
  game.player.nextLevelExperience.value = consumeInt();
  game.player.experiencePercentage.value = _consumePercentage();
  game.player.characterType.value = _consumeCharacterType();
  game.player.abilityTarget.x = consumeDouble();
  game.player.abilityTarget.y = consumeDouble();
  game.player.abilityRange = consumeDouble();
  game.player.abilityRadius = consumeDouble();
  game.player.ability.value = _consumeAbilityType();
  game.player.magic.value = consumeDouble();
  game.player.maxMagic.value = consumeDouble();
  game.player.attackRange = consumeDouble();
  game.player.team = consumeInt();
}

AbilityType _consumeAbilityType() {
  return abilities[consumeInt()];
}

CharacterType _consumeCharacterType() {
  return characterTypes[consumeInt()];
}

void _parsePlayerEvents() {
  int total = consumeInt();
  for (int i = 0; i < total; i++) {
    PlayerEvent event = _consumePlayerEventType();
    switch (event) {
      case PlayerEvent.Level_Up:
        emitPixelExplosion(game.player.x, game.player.y, amount: 10);
        playAudioBuff1(game.player.x, game.player.y);
        break;
      case PlayerEvent.Skill_Upgraded:
        playAudio.unlock(game.player.x, game.player.y);
        break;
      case PlayerEvent.Dash_Activated:
        playAudio.buff11(game.player.x, game.player.y);
        break;
    }
  }
}

PlayerEvent _consumePlayerEventType() {
  return playerEvents[consumeInt()];
}

void _parseCollectables() {
  // todo this is really expensive
  game.collectables.clear();
  while (!_simiColonConsumed()) {
    game.collectables.add(consumeInt());
  }
}

void _parseGrenades() {
  game.grenades.clear();
  while (!_simiColonConsumed()) {
    game.grenades.add(consumeDouble());
  }
}

void _parseGameJoined() {
  game.player.id = consumeInt();
  game.player.uuid.value = _consumeString();
  game.player.x = consumeDouble();
  game.player.y = consumeDouble();
  game.id = consumeInt();
  game.player.squad = consumeInt();
  print(      "ServerResponse.Game_Joined: playerId: ${game.player.id} gameId: ${game.id}");
}

ObjectType _consumeEnvironmentObjectType() {
  return objectTypes[consumeInt()];
}

void _next() {
  _index++;
}

void _consumeSpace() {
  while (_currentCharacter == _space) {
    _next();
  }
}

void _consumeAbility(Ability ability) {
  ability.type.value = _consumeAbilityType();
  ability.level.value = consumeInt();
  ability.cooldown.value = consumeInt();
  ability.cooldownRemaining.value = consumeInt();
  ability.magicCost.value = consumeInt();
}

int consumeInt() {
  final String string = _consumeString();
  final int? value = int.tryParse(string);
  if (value == null) {
    throw Exception("could not parse $string to int");
  }
  return value;
}

int _consumeIntUnsafe() {
  return int.parse(_consumeStringUnsafe());
}

int _consumeSingleDigitInt() {
  return int.parse(_consumeSingleCharacter());
}

WeaponType _consumeWeaponType() {
  return weaponTypes[_consumeSingleDigitInt()];
}

Weapon _consumeWeapon() {
  WeaponType type = _consumeWeaponType();
  int rounds = _consumeIntUnsafe();
  int capacity = _consumeIntUnsafe();
  int damage = consumeInt();
  return Weapon(type: type, rounds: rounds, capacity: capacity, damage: damage);
}

CharacterState _consumeCharacterState() {
  return characterStates[_consumeSingleDigitInt()];
}

Direction _consumeDirection() {
  return directions[_consumeSingleDigitInt()];
}

Tile _consumeTile() {
  return tiles[consumeInt()];
}

ServerResponse _consumeServerResponse() {
  int responseInt = consumeInt();
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

final StringBuffer _consumer = StringBuffer();

/// This is an optimized version of consume string
/// It has all error checking removed
String _consumeStringUnsafe() {
  _consumer.clear();
  String char = _currentCharacter;
  while (char != _space) {
    _consumer.write(char);
    _index++;
    char = _currentCharacter;
  }
  _index++;
  return _consumer.toString();
}

String _consumeSingleCharacter() {
  String char = _currentCharacter;
  _index += 2;
  return char;
}

double consumeDouble() {
  return double.parse(_consumeString());
}

double _consumePercentage() {
  return consumeDouble() * 0.01;
}

double _consumeDoubleUnsafe() {
  return double.parse(_consumeStringUnsafe());
}

Vector2 _consumeVector2() {
  return Vector2(consumeDouble(), consumeDouble());
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
  game.totalHumans = consumeInt();
  for (int i = 0; i < game.totalHumans; i++) {
    _consumeHuman(game.humans[i]);
  }
}

GameError _consumeError() {
  return GameError.values[consumeInt()];
}

void _consumeEvents() {
  int events = 0;
  while (!_simiColonConsumed()) {
    events++;
    int id = consumeInt();
    GameEventType type = _consumeEventType();
    double x = consumeDouble();
    double y = consumeDouble();
    double xv = consumeDouble();
    double yv = consumeDouble();
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
  return gameEventTypes[consumeInt()];
}

ItemType _consumeItemType() {
  return itemTypes[consumeInt()];
}

void _parseProjectiles() {
  game.totalProjectiles = 0;
  while (!_simiColonConsumed()) {
    Projectile projectile = game.projectiles[game.totalProjectiles];
    projectile.x = consumeDouble();
    projectile.y = consumeDouble();
    projectile.type = _consumeProjectileType();
    projectile.direction = _consumeDirection();
    game.totalProjectiles++;
  }
}

ProjectileType _consumeProjectileType() {
  return projectileTypes[consumeInt()];
}

void _parseZombies() {
  game.totalZombies.value = consumeInt();
  for (int i = 0; i < game.totalZombies.value; i++) {
    _consumeZombie(game.zombies[i]);
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
  character.type = _consumeCharacterType();
  character.state = _consumeCharacterState();
  character.direction = _consumeDirection();
  character.x = consumeDouble();
  character.y = consumeDouble();
  character.frame = consumeInt();
  character.team = consumeInt();
  character.name = _consumeString();

  StringBuffer textBuffer = StringBuffer();
  while (!_commaConsumed()) {
    textBuffer.write(_consumeString());
    textBuffer.write(_space);
  }
  character.text = textBuffer.toString().trim();
  character.health = _consumePercentage();
  character.magic = _consumePercentage();
}

void _consumeZombie(Zombie zombie) {
  zombie.state = _consumeCharacterState();
  zombie.direction = _consumeDirection();
  zombie.x = _consumeDoubleUnsafe();
  zombie.y = _consumeDoubleUnsafe();
  zombie.frame = _consumeIntUnsafe();
  zombie.health = _consumePercentage();
  zombie.team = consumeInt();
}

void _consumeInteractableNpc(Character interactableNpc) {
  interactableNpc.state = _consumeCharacterState();
  interactableNpc.direction = _consumeDirection();
  interactableNpc.x = consumeDouble();
  interactableNpc.y = consumeDouble();
  interactableNpc.frame = consumeInt();
  interactableNpc.name = _consumeString();
}

Shade _consumeShade() {
  return shades[consumeInt()];
}

