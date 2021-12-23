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
int actualFPS = 0;
Map<int, bool> gameEvents = Map();

bool get playerReady =>
    game.totalHumans > 0 &&
    game.player.x != -1 &&
    game.player.y != -1;


