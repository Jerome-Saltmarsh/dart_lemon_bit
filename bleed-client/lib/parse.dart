
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
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/parser/parseCubePlayers.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils/list_util.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/Vector2.dart';

import 'common/GameEventType.dart';
import 'common/PlayerEvent.dart';
import 'common/Tile.dart';
import 'common/WeaponType.dart';
import 'common/enums/ObjectType.dart';

// state
int _index = 0;
// constants
const String _space = " ";
const String _semiColon = ";";
const String _comma = ",";

// enums
const List<ServerResponse> serverResponses = ServerResponse.values;
const List<GameEventType> gameEventTypes = GameEventType.values;

String event = "";

String get _currentCharacter {
  // debug mode
  // if (_index >= compiledGame.length){
  //   throw Exception("parser exceeded length while parsing $_currentServerResponse");
  // }
  return event[_index];
}

late ServerResponse _currentServerResponse;

// functions
void parseState() {
  _index = 0;
  event = event.trim();
  while (_index < event.length) {
    _currentServerResponse = _consumeServerResponse();
    switch (_currentServerResponse) {
      case ServerResponse.Tiles:
        _parseTiles();
        break;

      case ServerResponse.Paths:
        _parsePaths();
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
        modules.game.state.player.attackTarget.x = consumeDouble();
        modules.game.state.player.attackTarget.y = consumeDouble();

        if (modules.game.state.player.attackTarget.x != 0 &&
            modules.game.state.player.attackTarget.y != 0) {
          engine.state.cursorType.value = CursorType.Click;
        } else {
          engine.state.cursorType.value = CursorType.Basic;
        }
        break;

      case ServerResponse.Player_Abilities:
        _consumeAbility(modules.game.state.player.ability1);
        _consumeAbility(modules.game.state.player.ability2);
        _consumeAbility(modules.game.state.player.ability3);
        _consumeAbility(modules.game.state.player.ability4);
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

      case ServerResponse.Players:
        _parsePlayers();
        break;

      case ServerResponse.Version:
        // sendRequestJoinGame();
        break;

      case ServerResponse.Error:
        GameError error = _consumeError();
        pub(error);
        return;

      case ServerResponse.Bullets:
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
        double x = consumeDouble();
        double y = consumeDouble();
        modules.game.state.player.x = x;
        modules.game.state.player.y = y;
        engine.actions.cameraCenter(x, y);

        Future.delayed(Duration(milliseconds: 150), () {
          engine.actions.cameraCenter(x, y);
        });
        for (Particle particle in isometric.state.particles) {
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
        modules.game.state.player.message.value = message.trim();
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
        modules.game.state.status.value = gameStatuses[consumeInt()];
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

      case ServerResponse.Items:
        game.itemsTotal = consumeInt();
        for (int i = 0; i < game.itemsTotal; i++) {
          Item item = game.items[i];
          item.type = _consumeItemType();
          item.x = consumeDouble();
          item.y = consumeDouble();
        }
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
  modules.isometric.state.time.value = consumeInt();
}

void parseItems() {
  game.itemsTotal = consumeInt();
  for(int i = 0; i < game.itemsTotal; i++){
    final item = game.items[i];
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
  print("parseEnvironmentObjects()");
  modules.isometric.state.environmentObjects.clear();
  game.torches.clear();

  while (!_simiColonConsumed()) {
    double x = consumeDouble();
    double y = consumeDouble();
    double radius = consumeDouble();
    ObjectType type = _consumeEnvironmentObjectType();

    switch (type) {
      case ObjectType.SmokeEmitter:
        addParticleEmitter(
            ParticleEmitter(x: x, y: y, rate: 20, emit: modules.game.factories.buildParticleSmoke));
        break;
      case ObjectType.MystEmitter:
        addParticleEmitter(
            ParticleEmitter(x: x, y: y, rate: 20, emit: modules.game.factories.emitMyst));
        break;
      case ObjectType.Torch:
        // addParticleEmitter(ParticleEmitter(x: x, y: y - 40, rate: 75, emit: emitPixel));
        break;
      default:
        // ignore
        break;
    }

    final EnvironmentObject env = EnvironmentObject(
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
  modules.isometric.actions.applyEnvironmentObjectsToBakeMapping();
}

void addParticleEmitter(ParticleEmitter value) {
  game.particleEmitters.add(value);
}

double environmentObjectY(EnvironmentObject environmentObject) {
  return environmentObject.y;
}

void _parsePaths() {
  isometric.state.paths.clear();
  while (!_simiColonConsumed()) {
    final List<Vector2> path = [];
    isometric.state.paths.add(path);
    while (!_commaConsumed()) {
      path.add(_consumeVector2());
    }
  }
}

void _parseTiles() {
  modules.isometric.state.totalRows.value = consumeInt();
  modules.isometric.state.totalColumns.value = consumeInt();
  print("parse.tiles(rows: ${modules.isometric.state.totalRows.value}, columns: ${modules.isometric.state.totalColumns.value})");
  isometric.state.tiles.clear();
  for (int row = 0; row < modules.isometric.state.totalRows.value; row++) {
    List<Tile> column = [];
    for (int columnIndex = 0; columnIndex < modules.isometric.state.totalColumns.value; columnIndex++) {
      column.add(_consumeTile());
    }
    isometric.state.tiles.add(column);
  }
  modules.isometric.actions.updateTileRender();
}

void _parsePlayer() {
  final player = modules.game.state.player;
  player.x = consumeDouble();
  player.y = consumeDouble();
  player.health.value = consumeDouble();
  player.maxHealth = consumeDouble();
  player.state.value = _consumeCharacterState();
  player.tile = _consumeTile();
  player.experience.value = consumeInt();
  player.level.value = consumeInt();
  player.skillPoints.value = consumeInt();
  player.nextLevelExperience.value = consumeInt();
  player.experiencePercentage.value = _consumePercentage();
  player.characterType.value = _consumeCharacterType();
  player.abilityTarget.x = consumeDouble();
  player.abilityTarget.y = consumeDouble();
  player.magic.value = consumeDouble();
  player.maxMagic.value = consumeDouble();
  player.attackRange = consumeDouble();
  player.team = consumeInt();
  player.slots.weapon.value = consumeSlotType();
  player.slots.armour.value = consumeSlotType();
  player.slots.helm.value = consumeSlotType();
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
  int total = consumeInt();
  for (int i = 0; i < total; i++) {
    PlayerEvent event = _consumePlayerEventType();
    switch (event) {
      case PlayerEvent.Level_Up:
        modules.game.actions.emitPixelExplosion(modules.game.state.player.x, modules.game.state.player.y, amount: 10);
        playAudioBuff1(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Skill_Upgraded:
        playAudio.unlock(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Dash_Activated:
        playAudio.buff11(modules.game.state.player.x, modules.game.state.player.y);
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
  modules.game.state.player.id = consumeInt();
  modules.game.state.player.uuid.value = _consumeString();
  modules.game.state.player.x = consumeDouble();
  modules.game.state.player.y = consumeDouble();
  game.id = consumeInt();
  modules.game.state.player.team = consumeInt();
  print("ServerResponse.Game_Joined: playerId: ${modules.game.state.player.id} gameId: ${game.id}");
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

SlotType consumeSlotType(){
   return slotTypesAll[_consumeIntUnsafe()];
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
  while (_index < event.length && _currentCharacter != _space) {
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
    if (!game.gameEvents.containsKey(id)) {
      game.gameEvents[id] = true;
      modules.game.events.onGameEvent(type, x, y, xv, yv);
    }
  }
  if (events == 0) {
    game.gameEvents.clear(); // free up memory
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
  character.weapon = _consumeWeaponType();
  character.equippedSlotType = consumeSlotType();
  character.equippedArmour = consumeSlotType();
  character.equippedHead = consumeSlotType();
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

int _consumeShade() {
  return consumeInt();
}

