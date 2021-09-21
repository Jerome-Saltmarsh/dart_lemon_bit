
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/enums.dart';

class Player {
  int equippedRounds = 0;
  int equippedClips = 0;
  int stamina = 0;
  int staminaMax = 0;
  int squad = -1;
  int points = 0;
  double health = 0;
  double maxHealth = 0;
  CharacterState state = CharacterState.Idle;
  bool acquiredHandgun = false;
  bool acquiredShotgun = false;
  bool acquiredSniperRifle = false;
  bool acquiredAssaultRifle = false;
  Tile tile = Tile.Grass;

  bool get dead => state == CharacterState.Dead;
  bool get alive => !dead;
  bool get canPurchase => tile == Tile.PlayerSpawn;
}