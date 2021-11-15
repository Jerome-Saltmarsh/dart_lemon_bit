
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/enums.dart';
import 'package:lemon_watch/watch.dart';

class Player {
  Watch<int> equippedRounds = Watch(0);
  int equippedClips = 0;
  int stamina = 0;
  int staminaMax = 0;
  int squad = -1;
  int points = 0;
  int credits = 0;
  Watch<double> health = Watch(0.0);
  double maxHealth = 0;
  bool acquiredHandgun = false;
  bool acquiredShotgun = false;
  bool acquiredSniperRifle = false;
  bool acquiredAssaultRifle = false;
  Tile tile = Tile.Grass;
  int grenades = 0;
  int meds = 0;
  int roundsHandgun;
  int roundsShotgun;
  int roundsSniperRifle = 0;
  int roundsAssaultRifle = 0;
  Watch<String> message = Watch("");
  Watch<CharacterState> state = Watch(CharacterState.Idle);
  Watch<bool> alive = Watch(true);
  bool get dead => !alive.value;
  // bool get canPurchase => tile == Tile.PlayerSpawn;
  bool get canPurchase => false;
}

