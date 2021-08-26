import 'package:bleed_client/editor/GameEdit.dart';

import '../common.dart';
import 'classes/Block.dart';
import 'classes/SpriteAnimation.dart';
import 'classes/Vector2.dart';
import 'enums/Mode.dart';
import 'instances/game.dart';

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
int gameId = -1;
int serverFramesMS = 0;
int actualFPS;
List<Block> blockHouses = [];
Map<int, bool> gameEvents = Map();

// Player State
double playerHealth = 0;
double playerMaxHealth = 0;
int playerStamina = 0;
int playerMaxStamina = 0;

// TODO Expensive string build
String get session => '$gameId ${compiledGame.playerId} ${compiledGame.playerUUID}';

