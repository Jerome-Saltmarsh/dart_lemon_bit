import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/PlayerEvents.dart';
import '../common/Quests.dart';
import '../constants/no_squad.dart';
import '../common/Tile.dart';
import '../functions/generateName.dart';
import '../functions/generateUUID.dart';
import '../settings.dart';
import 'Character.dart';
import 'Game.dart';
import 'Inventory.dart';
import 'Weapon.dart';


class Player extends Character {
  final String uuid = generateUUID();
  String name = generateName();
  int lastUpdateFrame = 0;
  Inventory inventory;
  int grenades;
  int lives;
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
  int skillPoints = 0;

  Tile currentTile = Tile.PlayerSpawn;
  CharacterState characterState = CharacterState.Idle;

  final List<PlayerEvent> events = [];

  void addEvent(PlayerEventType type, int value) {
    for (PlayerEvent event in events) {
      if (event.sent) continue;
      event.sent = false;
      event.type = type;
      event.value = value;
      return;
    }
    events.add(PlayerEvent(type, value));
  }

  Player({
    required double x,
    required double y,
    required this.inventory,
    required this.game,
    this.grenades = 0,
    this.lives = 0,
    required List<Weapon> weapons,
    int squad = noSquad,
  }) : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            weapons: weapons,
            health: settings.health.player,
            speed: settings.playerSpeed,
            squad: squad);
}
