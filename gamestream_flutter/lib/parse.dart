
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';

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

      case ServerResponse.Game_Time:
        parseGameTime();
        break;

      // case ServerResponse.Lobby_CountDown:
      //   game.countDownFramesRemaining.value = consumeInt();
      //   break;

      // case ServerResponse.NpcsDebug:
      //   game.npcDebug.clear();
      //   while (!_simiColonConsumed()) {
      //     game.npcDebug.add(NpcDebug(
      //       x: consumeDouble(),
      //       y: consumeDouble(),
      //       targetX: consumeDouble(),
      //       targetY: consumeDouble(),
      //     ));
      //   }
      //   break;
      //
      // case ServerResponse.Waiting_For_More_Players:
      //   game.numberOfPlayersNeeded.value = consumeInt();
      //   break;
      //
      // case ServerResponse.Team_Lives_Remaining:
      //   game.teamLivesWest.value = consumeInt();
      //   game.teamLivesEast.value = consumeInt();
      //   break;
      //
      // case ServerResponse.Game_Meta:
      //   game.teamSize.value = consumeInt();
      //   game.numberOfTeams.value = consumeInt();
      //   break;

      case ServerResponse.Version:
        break;

      case ServerResponse.Error:
        GameError error = _consumeError();
        pub(error);
        return;

      case ServerResponse.Scene_Shade_Max:
        modules.isometric.maxAmbientBrightness.value = _consumeShade();
        break;

      case ServerResponse.Scene_Changed:
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

      case ServerResponse.NpcMessage:
        String message = "";
        while (!_simiColonConsumed()) {
          message += _consumeString();
          message += " ";
        }
        modules.game.state.player.message.value = message.trim();
        break;

      // case ServerResponse.Debug_Mode:
      //   final debugInt = _consumeSingleDigitInt();
      //   modules.game.state.debug.value = debugInt == 1;
      //   break;

      case ServerResponse.Grenades:
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

      // case ServerResponse.Game_Royal:
      //   game.royal.mapCenter = _consumeVector2();
      //   game.royal.radius = consumeDouble();
      //   break;
      //
      // case ServerResponse.Lobby:
      //   game.lobby.playerCount.value = consumeInt();
      //   game.lobby.players.clear();
      //   for (int i = 0; i < game.lobby.playerCount.value; i++) {
      //     String name = _consumeString();
      //     int team = consumeInt();
      //     game.lobby.add(team: team, name: name);
      //   }
      //   break;

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
  player.team = consumeInt();
  player.x = consumeDouble();
  player.y = consumeDouble();

  final particles = modules.isometric.particles;
  for(final particle in particles) {
    particle.duration = 0;
  }
  cameraCenterOnPlayer();
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

OrbType consumeOrbType(){
  return orbTypes[consumeInt()];
}

double consumeDouble() {
  return double.parse(_consumeString());
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

int _consumeShade() {
  return consumeInt();
}

