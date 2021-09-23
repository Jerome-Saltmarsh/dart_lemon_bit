import 'package:bleed_client/classes/CompiledGame.dart';
import 'package:bleed_client/classes/Player.dart';
import 'package:bleed_client/classes/Score.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/editor/GameEdit.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/utils.dart';

import '../common.dart';
import 'classes/Block.dart';
import 'classes/SpriteAnimation.dart';
import 'classes/State.dart';
import 'enums/Mode.dart';
import 'keys.dart';

GameEdit gameEdit;
Mode mode = Mode.Play;
int frameRate = 5;
int frameRateValue = 0;
int packagesSent = 0;
int packagesReceived = 0;
int pass = 0;
int serverFrame = 0;
int requestDirection = directionDown;
int requestCharacterState = characterStateIdle;
double requestAim = 0;
DateTime previousEvent = DateTime.now();
int framesSinceEvent = 0;
int lag = 0;
Duration ping;
String event = "";
dynamic valueObject;
DateTime lastRefresh = DateTime.now();
Duration refreshDuration;
List<SpriteAnimation> animations = [];
int drawFrame = 0;
bool debugMode = false;
bool gameOver = false;
int serverFramesMS = 0;
int actualFPS;
List<Block> blockHouses = [];
Map<int, bool> gameEvents = Map();

dynamic get getPlayer {
  if (!playerAssigned) return null;
  if (!playerReady) return null;
  if (compiledGame.totalPlayers == 0) return null;
  for (dynamic player in compiledGame.players) {
    if (player[x] != compiledGame.playerX) continue;
    if (player[y] != compiledGame.playerY) continue;
    return player;
  }
  return null;
}

Weapon get playerWeapon => getPlayer[weapon];

List<CharacterState> characterStates = CharacterState.values;

CharacterState get playerState {
  return characterStates[getPlayer[stateIndex]];
}

bool get playerReady =>
    compiledGame.totalPlayers > 0 &&
    compiledGame.playerX != -1 &&
    compiledGame.playerY != -1;

String get playerName {
  return getPlayer[indexName];
}

// TODO Expensive string build
String get session =>
    '${compiledGame.gameId} ${compiledGame.playerId} ${compiledGame.playerUUID}';

State state = State();

Player get player => state.player;

CompiledGame get compiledGame => state.compiledGame;

bool get gameStarted => state.compiledGame.gameId >= 0;

double get playerX => compiledGame.playerX;

double get playerY => compiledGame.playerY;

Score get highScore {
  if (state.score.isEmpty) return null;
  Score highScore = state.score.first;
  for (Score score in state.score) {
    if (score.record <= highScore.record) continue;
    highScore = score;
  }
  return highScore;
}

int clipsRemaining(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      return player.clipsHandgun;
    case Weapon.Shotgun:
      return player.clipsShotgun;
    case Weapon.SniperRifle:
      return player.clipsSniperRifle;
    case Weapon.AssaultRifle:
      return player.clipsAssaultRifle;
    default:
      throw Exception("Could not get clips for $weapon");
  }
}

bool weaponAcquired(Weapon weapon) {
  switch (weapon) {
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
