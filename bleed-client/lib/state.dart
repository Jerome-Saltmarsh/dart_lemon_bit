import 'package:bleed_client/state/game.dart';

int frameRate = 5;
int frameRateValue = 0;
int serverFrame = 0;
DateTime previousEvent = DateTime.now();
int framesSinceEvent = 0;
int lag = 0;
dynamic valueObject;
DateTime lastRefresh = DateTime.now();
int drawFrame = 0;
int serverFramesMS = 0;
int actualFPS;
Map<int, bool> gameEvents = Map();

bool get playerReady =>
    game.totalHumans > 0 &&
    game.playerX != -1 &&
    game.playerY != -1;

// TODO Expensive string build
String get session =>
    '${game.gameId} ${game.playerId} ${game.playerUUID}';


bool get gameStarted => game.gameId >= 0;

double get playerX => game.playerX;

double get playerY => game.playerY;

