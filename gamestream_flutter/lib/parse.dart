
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/classes/Ability.dart';
import 'package:gamestream_flutter/classes/Character.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/NpcDebug.dart';
import 'package:gamestream_flutter/classes/ParticleEmitter.dart';
import 'package:gamestream_flutter/classes/Weapon.dart';
import 'package:bleed_common/AbilityType.dart';
import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/GameError.dart';
import 'package:bleed_common/GameStatus.dart';
import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/OrbType.dart';
import 'package:bleed_common/PlayerEvent.dart';
import 'package:bleed_common/ServerResponse.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:bleed_common/enums/ObjectType.dart';
import 'package:bleed_common/enums/ProjectileType.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/parser/parseCubePlayers.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:gamestream_flutter/utils/list_util.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/Vector2.dart';

import 'package:bleed_common/GameEventType.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/WeaponType.dart';
import 'package:bleed_common/constants.dart';

// variables
var event = "";
var _index = 0;
// constants
const _space = " ";
const _semiColon = ";";
const _comma = ",";
const _onePercent = 0.01;
// finals
final _consumer = StringBuffer();
final _stringBuffer = StringBuffer();

String get _currentCharacter {
  return event[_index];
}

// functions
void parseState() {
  _index = 0;
  modules.game.state.smoothed = 10;
  final eventLength = event.length;
  while (_index < eventLength) {
    final _currentServerResponse = _consumeServerResponse();
    switch (_currentServerResponse) {
      case ServerResponse.Tiles:
        _parseTiles();
        break;

      case ServerResponse.Gem_Spawns:
        print("ServerResponse.Gem_Spawns");
        final total = consumeInt();
        for (var i = 0; i < total; i++) {
          final type = consumeOrbType();
          final x = consumeDouble();
          final y = consumeDouble();
          isometric.spawn.orb(type, x, y);
        }
        break;

      // case ServerResponse.Paths:
      //   _parsePaths();
      //   break;

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

      case ServerResponse.Player_Slot_Types:
        final slots = modules.game.state.player.slots;
        slots.slot1.value = consumeSlotType();
        slots.slot2.value = consumeSlotType();
        slots.slot3.value = consumeSlotType();
        slots.slot4.value = consumeSlotType();
        slots.slot5.value = consumeSlotType();
        slots.slot6.value = consumeSlotType();
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

      case ServerResponse.Player_Weapon:
        modules.game.state.soldier.weaponType.value = _consumeWeaponType();
        modules.game.state.soldier.weaponRounds.value = consumeInt();
        modules.game.state.soldier.weaponCapacity.value = consumeInt();
        break;

      case ServerResponse.Weapons:
        modules.game.state.soldier.weapons.clear();
        int length = _consumeIntUnsafe();
        for (int i = 0; i < length; i++) {
          modules.game.state.soldier.weapons.add(_consumeWeapon());
        }
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

      case ServerResponse.Npcs:
        _parseNpcs();
        break;

      case ServerResponse.Scene_Shade_Max:
        modules.isometric.state.maxAmbientBrightness.value = _consumeShade();
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
        isometric.state.particles.clear();
        isometric.state.next = null;
        break;

      case ServerResponse.EnvironmentObjects:
        isometric.state.particleEmitters.clear();
        _parseEnvironmentObjects();
        break;

      case ServerResponse.Game_Events:
        _consumeGameEvents();
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

      case ServerResponse.Items:
        parseItems();
        break;

      case ServerResponse.Crates:
        parseCrates();
        break;
      case ServerResponse.Grenades:
        _parseGrenades();
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
        modules.game.state.player.uuid.value = _consumeString();
        break;

      case ServerResponse.Cube_Players:
        parseCubePlayers();
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

      case ServerResponse.Collectables:
        if (game.id < 0) return;
        _parseCollectables();
        break;

      case ServerResponse.Player_Events:
        _parsePlayerEvents();
        return;

      case ServerResponse.Player_Ability:
        _parsePlayerAbility();
        break;

      case ServerResponse.Player:
        _parsePlayer();
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
  modules.isometric.state.minutes.value = consumeInt();
}

void parseItems() {
  game.itemsTotal = consumeInt();
  final items = isometric.state.items;
  for (int i = 0; i < game.itemsTotal; i++) {
    final item = items[i];
    item.type = _consumeItemType();
    item.x = consumeDouble();
    item.y = consumeDouble();
  }
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
  modules.isometric.state.environmentObjects.clear();
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

    modules.isometric.state.environmentObjects.add(env);
  }

  // * on environmentObjects changed
  sortReversed(modules.isometric.state.environmentObjects, environmentObjectY);
  modules.isometric.actions.resetLighting();
}

void addParticleEmitter(ParticleEmitter value) {
  isometric.state.particleEmitters.add(value);
}

double environmentObjectY(EnvironmentObject environmentObject) {
  return environmentObject.y;
}

// void _parsePaths() {
//   isometric.state.paths.clear();
//   while (!_simiColonConsumed()) {
//     final List<Vector2> path = [];
//     isometric.state.paths.add(path);
//     while (!_commaConsumed()) {
//       path.add(_consumeVector2());
//     }
//   }
// }

void _parseTiles() {
  print("parse.tiles()");
  final isometric = modules.isometric;
  final isometricState = isometric.state;
  final rows = consumeInt();
  final columns = consumeInt();
  final tiles = isometricState.tiles;
  tiles.clear();
  isometricState.totalRows.value = rows;
  isometricState.totalColumns.value = columns;
  isometricState.totalRowsInt = rows;
  isometricState.totalColumnsInt = columns;
  for (var row = 0; row < rows; row++) {
    final List<Tile> column = [];
    for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
      column.add(_consumeTile());
    }
    tiles.add(column);
  }
  isometric.actions.updateTileRender();
}

void _parsePlayer() {
  // final player = modules.game.state.player;
  // player.character.x = _consumeDoubleUnsafe();
  // player..character.y = _consumeDoubleUnsafe();
  // player.health.value = _consumeDoubleUnsafe();
  // player.maxHealth = _consumeDoubleUnsafe();
  // player.state.value = _consumeCharacterState();
  // player.experience.value = _consumeIntUnsafe();
  // player.level.value = _consumeIntUnsafe();
  // player.skillPoints.value = _consumeIntUnsafe();
  // player.nextLevelExperience.value = _consumeIntUnsafe();
  // player.experiencePercentage.value = _consumePercentage();
  // player.characterType.value = _consumeCharacterType();
  // player.abilityTarget.x = _consumeDoubleUnsafe();
  // player.abilityTarget.y = _consumeDoubleUnsafe();
  // player.magic.value = _consumeDoubleUnsafe();
  // player.maxMagic.value = _consumeDoubleUnsafe();
  // player.attackRange = _consumeDoubleUnsafe();
  // player.character.team = _consumeIntUnsafe();
  // player.slots.weapon.value = consumeSlotType();
  // player.slots.armour.value = consumeSlotType();
  // player.slots.helm.value = consumeSlotType();
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

CharacterType _consumeCharacterType() {
  return characterTypes[consumeInt()];
}

void _parsePlayerEvents() {
  final total = consumeInt();
  for (var i = 0; i < total; i++) {
    final event = _consumePlayerEventType();
    switch (event) {
      case PlayerEvent.Level_Up:
        modules.game.actions.emitPixelExplosion(modules.game.state.player.x, modules.game.state.player.y, amount: 10);
        audio.buff(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Skill_Upgraded:
        audio.unlock(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Dash_Activated:
        audio.buff11(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Item_Purchased:
        audio.itemPurchased(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Item_Equipped:
        audio.itemEquipped(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Item_Sold:
        audio.coins(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Drink_Potion:
        audio.bottle(screenCenterWorldX, screenCenterWorldY);
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
  print("parseGameJoined()");
  final player = modules.game.state.player;
  player.id = consumeInt();
  player.uuid.value = _consumeString();
  game.id = consumeInt();
  player.team = consumeInt();
  // final byteIdString = _consumeString();
  // player.byteId = byteIdString.split(":").map(int.parse).toList();
  // print("ServerResponse.Game_Joined: playerId: ${player.id} gameId: ${game.id} $byteId");
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
  final valueString = _consumeString();
  final value = int.tryParse(valueString);
  if (value == null) {
    throw Exception("could not parse $valueString to int");
  }
  return value;
}

SlotType consumeSlotType(){
   return slotTypes[_consumeIntUnsafe()];
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
  final type = _consumeWeaponType();
  final rounds = _consumeIntUnsafe();
  final capacity = _consumeIntUnsafe();
  final damage = consumeInt();
  return Weapon(type: type, rounds: rounds, capacity: capacity, damage: damage);
}

CharacterState _consumeCharacterState() {
  return characterStates[_consumeSingleDigitInt()];
}

Tile _consumeTile() {
  return tiles[consumeInt()];
}

ServerResponse _consumeServerResponse() {
  final responseInt = consumeInt();
  if (responseInt >= serverResponsesLength) {
    throw Exception('$responseInt is not a valid server response');
  }
  return serverResponses[responseInt];
}

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

double _consumePercentage() {
  return consumeDouble() * _onePercent;
}

double _consumeDoubleUnsafe() {
  return double.parse(_consumeStringUnsafe());
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

bool _commaConsumed() {
  _consumeSpace();
  if (_currentCharacter == _comma) {
    _index++;
    return true;
  }
  return false;
}

GameError _consumeError() {
  return GameError.values[consumeInt()];
}

void _consumeGameEvents() {
  final gameEvents = game.gameEvents;
  while (!_simiColonConsumed()) {
    final id = consumeInt();
    final type = _consumeEventType();
    final x = consumeDouble();
    final y = consumeDouble();
    final angle = consumeDouble();
    if (gameEvents.containsKey(id)) {
      continue;
    }
    gameEvents[id] = true;
    modules.game.events.onGameEvent(type, x, y, angle);
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


final _npcs = game.interactableNpcs;

void _parseNpcs() {
  game.totalNpcs = 0;
  while (!_simiColonConsumed()) {
    _consumeInteractableNpc(_npcs[game.totalNpcs]);
    game.totalNpcs++;
  }
}

void _consumeInteractableNpc(Character character) {
  character.state = _consumeCharacterState();
  character.direction = _consumeSingleDigitInt();
  character.x = consumeDouble();
  character.y = consumeDouble();
  character.frame = consumeInt();
  character.equippedWeapon = consumeSlotType();
  character.name = _consumeString();
}

int _consumeShade() {
  return consumeInt();
}

