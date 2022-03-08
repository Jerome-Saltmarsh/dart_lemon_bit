import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/ServerResponse.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/compile_util.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/state/game.dart';

final byteStreamParser = _ByteStreamParser();

const _100D = 100.0;
const _3 = 3;

class _ByteStreamParser {

  var _index = 0;
  late List<int> values;

  void parse(List<int> values){
    _index = 0;
    this.values = values;
    while (true) {
      final response = _nextServerResponse();
      switch(response){
        case ServerResponse.Zombies:
          _parseZombies();
          break;
        case ServerResponse.Players:
          _parsePlayers();
          break;
        case ServerResponse.Npcs:
          _parseNpcs();
          break;
        case ServerResponse.Projectiles:
          _parseProjectiles();
          break;
        case ServerResponse.End:
          return;

        default:
          throw Exception("Cannot parse $response");
      }
    }
  }

  void _parseProjectiles(){
    final total = _nextInt();
    final projectiles = game.projectiles;
    game.totalProjectiles = total;
    for (var i = 0; i < total; i++) {
      final projectile = projectiles[i];
      projectile.x = _nextDouble();
      projectile.y = _nextDouble();
      projectile.type = _readProjectileType();
      projectile.angle = _nextDouble();
    }
  }

  void _parseZombies() {
    final total = _nextInt();
    final zombies = game.zombies;
    game.totalZombies.value = total;
    for (var i = 0; i < total; i++){
      _readCharacter(zombies[i]);
    }
  }

  void _parsePlayers() {
    final total = _nextInt();
    final players = game.humans;
    game.totalHumans = total;
    for (var i = 0; i < total; i++){
      _readPlayer(players[i]);
    }
  }

  void _parseNpcs() {
    final total = _nextInt();
    final npcs = game.interactableNpcs;
    game.totalNpcs = total;
    for (var i = 0; i < total; i++){
      _readNpc(npcs[i]);
    }
  }

  void _readNpc(Character character){
    _readCharacter(character);
    character.equippedWeapon = _readSlotType();
  }

  void _readPlayer(Character character){
    _readCharacter(character);
    character.magic = _nextPercentage();
    character.equippedWeapon = _readSlotType();
    character.equippedArmour = _readSlotType();
    character.equippedHead = _readSlotType();
  }

  void _readCharacter(Character character){
     character.state = _readCharacterState();
     character.direction = _nextByte();
     character.x = _nextDouble();
     character.y = _nextDouble();
     character.frame = _nextByte();
     character.health = _nextPercentage();
     character.team = _nextByte();
  }

  CharacterState _readCharacterState(){
    return characterStates[_nextByte()];
  }

  SlotType _readSlotType(){
    return slotTypes[_nextByte()];
  }

  ProjectileType _readProjectileType(){
    return projectileTypes[_nextByte()];
  }

  double _nextPercentage(){
    return _nextByte() / _100D;
  }

  ServerResponse _nextServerResponse(){
    return serverResponses[_nextByte()];
  }

  int _nextByte(){
    final value = values[_index];
    _index++;
    return value;
  }

  int _nextInt(){
    final value = readInt(list: values, index: _index);
    _index += _3;
    return value;
  }

  double _nextDouble(){
    return _nextInt().toDouble();
  }
}