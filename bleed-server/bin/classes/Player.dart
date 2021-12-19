import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/PlayerEvent.dart';
import '../common/Quests.dart';
import '../constants/no_squad.dart';
import '../common/Tile.dart';
import '../functions/generateName.dart';
import '../functions/generateUUID.dart';
import '../settings.dart';
import '../utils.dart';
import 'Ability.dart';
import 'Character.dart';
import 'Game.dart';


class Player extends Character {
  final String uuid = generateUUID();
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

  Character? aimTarget; // the currently highlighted character

  int get magic => _magic;

  set magic(int value){
    _magic = clampInt(value, 0, maxMagic);
  }

  int maxMagic = 100;
  int magicRegen = 1;
  int healthRegen = 1;

  Tile currentTile = Tile.PlayerSpawn;
  CharacterState characterState = CharacterState.Idle;

  Ability ability1 = Ability(type: AbilityType.None, level: 0, magicCost: 0, range: 0, cooldown: 0);
  Ability ability2 = Ability(type: AbilityType.None, level: 0, magicCost: 0, range: 0, cooldown: 0);
  Ability ability3 = Ability(type: AbilityType.None, level: 0, magicCost: 0, range: 0, cooldown: 0);
  Ability ability4 = Ability(type: AbilityType.None, level: 0, magicCost: 0, range: 0, cooldown: 0);
  bool abilitiesDirty = true;

  final List<PlayerEvent> events = [];

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
    double x = 0,
    double y = 0,
    required this.game,
    int team = noSquad,
  }) : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            health: settings.health.player,
            speed: settings.playerSpeed,
            squad: team);
}
