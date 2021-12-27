import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/PlayerEvent.dart';
import '../common/Quests.dart';
import '../constants/no_squad.dart';
import '../common/Tile.dart';
import '../functions/generateName.dart';
import '../global.dart';
import '../settings.dart';
import '../utils.dart';
import 'Ability.dart';
import 'Character.dart';
import 'Entity.dart';
import 'Game.dart';


class Player extends Character with Entity {
  String name = generateName();
  int lastUpdateFrame = 0;
  int frameOfDeath = -1;
  int pointsRecord = 0;
  String message = "";
  String text = "";
  int textDuration = 0;
  MainQuest questMain = MainQuest.Introduction;
  bool sceneChanged = false;
  Game game;

  int handgunDamage = 10;

  int experience = 0;
  int level = 1;
  int abilityPoints = 0;
  int _magic = 0;

  Character? _aimTarget; // the currently highlighted character

  Character? get aimTarget => _aimTarget;

  set aimTarget(Character? value){
    if (value == null){
      _aimTarget = null;
      return;
    }
    if (value.team == team){
      throw Exception("cannot aim at same team");
    }
    if (value.dead){
      throw Exception("cannot aim at dead target");
    }
    if (!value.active){
      throw Exception("cannot aim at inactive target");
    }
    _aimTarget = value;
  }

  int get magic => _magic;

  set magic(int value){
    _magic = clampInt(value, 0, maxMagic);
  }

  int maxMagic = 100;
  int magicRegen = 1;
  int healthRegen = 1;

  Tile currentTile = Tile.PlayerSpawn;
  CharacterState characterState = CharacterState.Idle;

  Ability ability1 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0);
  Ability ability2 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0);
  Ability ability3 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0);
  Ability ability4 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0);
  bool abilitiesDirty = true;

  final List<PlayerEvent> events = [];

  bool get isHuman => type == CharacterType.Human;

  void dispatch(PlayerEvent event){
    events.add(event);
  }

  Ability getAbilityByIndex(int index){
    switch(index){
      case 1:
        return ability1;
      case 2:
        return ability2;
      case 3:
        return ability3;
      case 4:
        return ability4;
      default:
        throw Exception("could not get ability at index $index");
    }
  }

  Player({
    required this.game,
    double x = 0,
    double y = 0,
    int team = noSquad,
    CharacterType type = CharacterType.Human
  }) : super(
            type: type,
            x: x,
            y: y,
            health: settings.health.player,
            speed: settings.playerSpeed,
            team: team){
    global.onPlayerCreated(this);
  }
}
