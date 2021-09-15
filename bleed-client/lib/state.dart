import 'package:bleed_client/classes/CompiledGame.dart';
import 'package:bleed_client/classes/Player.dart';
import 'package:bleed_client/classes/Score.dart';
import 'package:bleed_client/editor/GameEdit.dart';
import 'package:bleed_client/enums.dart';

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
  for (dynamic player in compiledGame.players) {
    if (player[x] != compiledGame.playerX) continue;
    if (player[y] != compiledGame.playerY) continue;
    return player;
  }
}

List<CharacterState> characterStates = CharacterState.values;

CharacterState get playerState {
  return characterStates[getPlayer[stateIndex]];
}

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
