
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:lemon_watch/watch.dart';

class Player {
  Watch<int> equippedRounds = Watch(0);
  Watch<int> equippedCapacity = Watch(0);
  int squad = -1;
  Watch<double> health = Watch(0.0);
  double maxHealth = 0;
  Tile tile = Tile.Grass;
  Watch<int> experience = Watch(0);
  Watch<int> level = Watch(1);
  Watch<int> nextLevelExperience = Watch(1);
  Watch<int> experiencePercentage = Watch(1);
  int grenades = 0;
  Watch<String> message = Watch("");
  Watch<CharacterState> state = Watch(CharacterState.Idle);
  Watch<bool> alive = Watch(true);
  bool get dead => !alive.value;
  // bool get canPurchase => tile == Tile.PlayerSpawn;
  bool get canPurchase => false;
}

