import '../classes.dart';
import '../common/GameState.dart';
import '../common/PlayerEvents.dart';
import '../common/Quests.dart';
import '../common/Tile.dart';
import '../common/Weapons.dart';
import '../enums.dart';
import '../functions/generateName.dart';
import '../functions/generateUUID.dart';
import '../settings.dart';
import '../utils/player_utils.dart';
import 'Inventory.dart';
import 'Score.dart';


class Player extends Character {
  final String uuid = generateUUID();
  String name = generateName();
  int lastUpdateFrame = 0;
  int stamina = 0;
  int maxStamina = 200;
  Inventory inventory;
  int grenades;
  int meds;
  int lives;
  int frameOfDeath = -1;
  GameState gameState = GameState.InProgress;
  int _points = 0;
  int credits = 0;
  int pointsRecord = 0;
  Score score = Score();
  Clips clips = Clips();
  Rounds rounds = Rounds();
  String message = "";
  String text = "";
  int textDuration = 0;
  MainQuest questMain = MainQuest.Introduction;

  bool get acquiredHandgun => rounds.handgun > 0;
  bool get acquiredShotgun => rounds.shotgun > 0;
  bool get acquiredSniperRifle => rounds.sniperRifle > 0;
  bool get acquiredAssaultRifle => rounds.assaultRifle > 0;
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

  void earnPoints(int amount) {
    _points += amount;
    credits += amount;
    if (points > pointsRecord) {
      pointsRecord = points;
    }
  }

  void removeCredits(int amount){
    credits -= amount;
  }

  void resetPoints(){
    _points = 0;
    credits = 0;
  }

  int get points => _points;

  Player({
    required double x,
    required double y,
    required this.inventory,
    this.grenades = 0,
    this.meds = 0,
    this.lives = 0,
    required this.clips,
    required this.rounds,
    int squad = noSquad,
  }) : super(
            x: x,
            y: y,
            weapon: Weapon.HandGun,
            health: settings.health.player,
            speed: settings.playerSpeed,
            squad: squad) {
    stamina = maxStamina;
  }
}
