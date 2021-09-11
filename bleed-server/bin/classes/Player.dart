import '../classes.dart';
import '../common/GameState.dart';
import '../common/Weapons.dart';
import '../functions/generateUUID.dart';
import '../settings.dart';
import '../utils/player_utils.dart';
import 'Inventory.dart';

class Player extends Character {
  final String uuid = generateUUID();
  int lastEventFrame = 0;
  int stamina = 0;
  int maxStamina = 200;
  Inventory inventory;
  int grenades;
  int meds;
  int lives;
  int frameOfDeath = -1;
  GameState gameState = GameState.InProgress;

  Clips clips = Clips();
  Rounds rounds = Rounds();

  Player({
    required double x,
    required double y,
    required this.inventory,
    required String name,
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
            health: settingsPlayerStartHealth,
            maxHealth: settingsPlayerStartHealth,
            speed: playerSpeed,
            name: name,
            squad: squad
  ) {
    stamina = maxStamina;
  }
}
