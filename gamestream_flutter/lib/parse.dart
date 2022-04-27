
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/NpcDebug.dart';
import 'package:gamestream_flutter/classes/ParticleEmitter.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/utils/list_util.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';

// variables
var event = "";
var _index = 0;
// constants
const _space = " ";
const _semiColon = ";";
// finals
final _consumer = StringBuffer();
final _stringBuffer = StringBuffer();

String get _currentCharacter {
  return event[_index];
}

// functions
void parseState() {
  _index = 0;
  final eventLength = event.length;
  while (_index < eventLength) {
    final _currentServerResponse = consumeInt();
    switch (_currentServerResponse) {
      case ServerResponse.Tiles:
        _parseTiles();
        break;

      case ServerResponse.Gem_Spawns:
        final total = consumeInt();
        for (var i = 0; i < total; i++) {
          final type = consumeOrbType();
          final x = consumeDouble();
          final y = consumeDouble();
          isometric.spawn.orb(type, x, y);
        }
        break;

      case ServerResponse.Game_Time:
        parseGameTime();
        break;

      case ServerResponse.Lobby_CountDown:
        game.countDownFramesRemaining.value = consumeInt();
        break;

      case ServerResponse.Player_Orbs:
        final orbs = modules.game.state.player.orbs;
        orbs.ruby.value = consumeInt();
        orbs.topaz.value = consumeInt();
        orbs.emerald.value = consumeInt();
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
        final attackTarget = modules.game.state.player.attackTarget;
        attackTarget.x = consumeDouble();
        attackTarget.y = consumeDouble();
        if (attackTarget.x != 0 && attackTarget.y != 0) {
          engine.cursorType.value = CursorType.Click;
        } else {
          engine.cursorType.value = CursorType.Basic;
        }
        break;

      case ServerResponse.Team_Lives_Remaining:
        game.teamLivesWest.value = consumeInt();
        game.teamLivesEast.value = consumeInt();
        break;

      case ServerResponse.Game_Meta:
        game.teamSize.value = consumeInt();
        game.numberOfTeams.value = consumeInt();
        break;

      case ServerResponse.Version:
        // sendRequestJoinGame();
        break;

      case ServerResponse.Error:
        GameError error = _consumeError();
        pub(error);
        return;

      case ServerResponse.Projectiles:
        _parseProjectiles();
        break;

      case ServerResponse.Scene_Shade_Max:
        modules.isometric.maxAmbientBrightness.value = _consumeShade();
        break;

      case ServerResponse.Scene_Changed:
        print("ServerResponse.Scene_Changed");
        final x = consumeDouble();
        final y = consumeDouble();
        modules.game.state.player.x = x;
        modules.game.state.player.y = y;
        engine.cameraCenter(x, y);

        Future.delayed(Duration(milliseconds: 150), () {
          engine.cameraCenter(x, y);
        });
        isometric.particles.clear();
        isometric.next = null;
        break;

      case ServerResponse.EnvironmentObjects:
        isometric.particleEmitters.clear();
        _parseEnvironmentObjects();
        break;

      case ServerResponse.NpcMessage:
        String message = "";
        while (!_simiColonConsumed()) {
          message += _consumeString();
          message += " ";
        }
        modules.game.state.player.message.value = message.trim();
        break;

      case ServerResponse.Debug_Mode:
        final debugInt = _consumeSingleDigitInt();
        modules.game.state.compilePaths.value = debugInt == 1;
        break;

      // case ServerResponse.Items:
      //   parseItems();
      //   break;

      case ServerResponse.Crates:
        parseCrates();
        break;
      case ServerResponse.Grenades:
        break;

      case ServerResponse.Pong:
        break;

      case ServerResponse.Game_Joined:
        _parseGameJoined();
        break;

      case ServerResponse.Game_Type:
        final type = gameTypes[consumeInt()];
        break;

      case ServerResponse.Game_Status:
        core.state.status.value = gameStatuses[consumeInt()];
        break;

      case ServerResponse.Cube_Joined:
        // modules.game.state.player.uuid.value = _consumeString();
        break;

      case ServerResponse.Game_Royal:
        game.royal.mapCenter = _consumeVector2();
        game.royal.radius = consumeDouble();
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

      case ServerResponse.Player_Ability:
        _parsePlayerAbility();
        break;

      default:
        return;
    }

    while (_index < event.length) {
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

void parseGameTime() {
  modules.isometric.minutes.value = consumeInt();
}

void parseCrates() {
  game.cratesTotal = consumeInt();
  game.crates.clear();
  for (int i = 0; i < game.cratesTotal; i++) {
    game.crates.add(_consumeVector2());
  }
}

void _parseEnvironmentObjects() {
  print("parse.environmentObjects()");
  modules.isometric.environmentObjects.clear();
  game.torches.clear();

  while (!_simiColonConsumed()) {
    final x = consumeDouble();
    final y = consumeDouble();
    final radius = consumeDouble();
    final type = _consumeEnvironmentObjectType();

    if (type == ObjectType.SmokeEmitter){
      addParticleEmitter(
          ParticleEmitter(x: x, y: y, rate: 20, emit: modules.game.factories.buildParticleSmoke));
      continue;
    }

    if (type == ObjectType.MystEmitter){
      addParticleEmitter(
          ParticleEmitter(x: x, y: y, rate: 20, emit: modules.game.factories.emitMyst));
      continue;
    }

    final env = EnvironmentObject(
        x: x,
        y: y,
        type: type,
        radius: radius
    );

    if (type == ObjectType.Torch) {
      game.torches.add(env);
    }

    modules.isometric.environmentObjects.add(env);
  }

  modules.isometric.refreshGeneratedObjects();
  sortReversed(modules.isometric.environmentObjects, environmentObjectY);
  modules.isometric.resetLighting();
}

void addParticleEmitter(ParticleEmitter value) {
  isometric.particleEmitters.add(value);
}

double environmentObjectY(EnvironmentObject environmentObject) {
  return environmentObject.y;
}

void _parseTiles() {
  print("parse.tiles()");
  final isometric = modules.isometric;
  final rows = consumeInt();
  final columns = consumeInt();
  final tiles = isometric.tiles;
  tiles.clear();
  isometric.totalRows.value = rows;
  isometric.totalColumns.value = columns;
  isometric.totalRowsInt = rows;
  isometric.totalColumnsInt = columns;
  for (var row = 0; row < rows; row++) {
    final List<int> column = [];
    for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
      column.add(_consumeTile());
    }
    tiles.add(column);
  }

  isometric.refreshGeneratedObjects();
  isometric.updateTileRender();
}

void _parsePlayerAbility(){
  final player = modules.game.state.player;
  player.ability.value = _consumeAbilityType();
  player.abilityRange = consumeDouble();
  player.abilityRadius = consumeDouble();
}

AbilityType _consumeAbilityType() {
  return abilities[consumeInt()];
}

void _parseGameJoined() {
  print("parseGameJoined()");
  final player = modules.game.state.player;
  player.id = consumeInt();
  game.id = consumeInt();
  player.team = consumeInt();
  player.x = consumeDouble();
  player.y = consumeDouble();

  final particles = modules.isometric.particles;
  for(final particle in particles) {
    particle.duration = 0;
  }
  cameraCenterOnPlayer();
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

int consumeInt() {
  final valueString = _consumeString();
  final value = int.tryParse(valueString);
  if (value == null) {
    throw Exception("could not parse $valueString to int");
  }
  return value;
}

int consumeSlotType(){
   return _consumeIntUnsafe();
}

int _consumeIntUnsafe() {
  return int.parse(_consumeStringUnsafe());
}

int _consumeSingleDigitInt() {
  return int.parse(_consumeSingleCharacter());
}

int _consumeTile() {
  return consumeInt();
}

// ServerResponse _consumeServerResponse() {
//   final responseInt = consumeInt();
//   if (responseInt >= serverResponsesLength) {
//     throw Exception('$responseInt is not a valid server response');
//   }
//   return serverResponses[responseInt];
// }

String _consumeString() {
  _consumeSpace();
  _stringBuffer.clear();
  while (_index < event.length && _currentCharacter != _space) {
    _stringBuffer.write(_currentCharacter);
    _index++;
  }
  _index++;
  return _stringBuffer.toString();
}

/// This is an optimized version of consume string
/// It has all error checking removed
String _consumeStringUnsafe() {
  _consumer.clear();
  var char = _currentCharacter;
  while (char != _space) {
    _consumer.write(char);
    _index++;
    char = _currentCharacter;
  }
  _index++;
  return _consumer.toString();
}

String _consumeSingleCharacter() {
  var char = _currentCharacter;
  _index += 2;
  return char;
}

OrbType consumeOrbType(){
  return orbTypes[consumeInt()];
}

double consumeDouble() {
  return double.parse(_consumeString());
}

Vector2 _consumeVector2() {
  final x = _consumeIntUnsafe();
  final y = consumeDouble();
  return Vector2(x.toDouble(), y);
}

bool _simiColonConsumed() {
  _consumeSpace();
  if (_currentCharacter == _semiColon) {
    _index++;
    return true;
  }
  return false;
}

GameError _consumeError() {
  return GameError.values[consumeInt()];
}

void _parseProjectiles() {
  game.totalProjectiles = 0;
  while (!_simiColonConsumed()) {
    final projectile = game.projectiles[game.totalProjectiles];
    projectile.x = consumeDouble();
    projectile.y = consumeDouble();
    projectile.type = _consumeProjectileType();
    projectile.angle = consumeDouble() * degreesToRadians;
    game.totalProjectiles++;
  }
}

ProjectileType _consumeProjectileType() {
  return projectileTypes[consumeInt()];
}

int _consumeShade() {
  return consumeInt();
}

