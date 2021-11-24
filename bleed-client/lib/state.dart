import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Player.dart';
import 'package:bleed_client/classes/Score.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';

import 'classes/State.dart';
import 'enums/Mode.dart';

Mode mode = Mode.Play;
int frameRate = 5;
int frameRateValue = 0;
int serverFrame = 0;
double requestAim = 0;
DateTime previousEvent = DateTime.now();
int framesSinceEvent = 0;
int lag = 0;
dynamic valueObject;
DateTime lastRefresh = DateTime.now();
int drawFrame = 0;
int serverFramesMS = 0;
int actualFPS;
Map<int, bool> gameEvents = Map();

// TODO delete this
Character get getPlayer {
  if (!playerAssigned) return null;
  if (!playerReady) return null;
  if (game.totalHumans == 0) return null;
  for (Character player in game.humans) {
    if (player.x != game.playerX) continue;
    if (player.y != game.playerY) continue;
    return player;
  }
  return null;
}

bool get playerReady =>
    game.totalHumans > 0 &&
    game.playerX != -1 &&
    game.playerY != -1;

String get playerName => getPlayer.name;

// TODO Expensive string build
String get session =>
    '${game.gameId} ${game.playerId} ${game.playerUUID}';

State state = State();

Player get player => state.player;

bool get gameStarted => game.gameId >= 0;

double get playerX => game.playerX;

double get playerY => game.playerY;

Score get highScore {
  if (state.score.isEmpty) return null;
  Score highScore = state.score.first;
  for (Score score in state.score) {
    if (score.record <= highScore.record) continue;
    highScore = score;
  }
  return highScore;
}

int getWeaponRounds(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return player.roundsHandgun;
    case Weapon.Shotgun:
      return player.roundsShotgun;
    case Weapon.SniperRifle:
      return player.roundsSniperRifle;
    case Weapon.AssaultRifle:
      return player.roundsAssaultRifle;
    default:
      throw Exception("Could not get clips for $weapon");
  }
}

bool weaponAcquired(Weapon weapon) {
  switch (weapon) {
    case Weapon.Unarmed:
      return true;
    case Weapon.HandGun:
      return player.acquiredHandgun;
    case Weapon.Shotgun:
      return player.acquiredShotgun;
    case Weapon.SniperRifle:
      return player.acquiredSniperRifle;
    case Weapon.AssaultRifle:
      return player.acquiredAssaultRifle;
    default:
      throw Exception("Could not get acquired for $weapon");
  }
}
