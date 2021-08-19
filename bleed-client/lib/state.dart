import 'dart:ui';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/enums/Weapons.dart';
import 'package:flutter/material.dart';

import '../common.dart';
import 'classes/Block.dart';
import 'classes/SpriteAnimation.dart';
import 'enums/Mode.dart';
import 'instances/game.dart';

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
List<RSTransform> playersTransforms = [];
List<Rect> playersRects = [];
List<RSTransform> npcsTransforms = [];
List<Rect> particleRects = [];
List<RSTransform> particleTransforms = [];
List<Rect> npcsRects = [];
int tilesX = 0;
int tilesY = 0;
List<Block> blockHouses = [];
List<RSTransform> tileTransforms = [];
List<Rect> tileRects = [];
Map<int, bool> gameEvents = Map();

// Player State
double playerHealth = 0;
double playerMaxHealth = 0;
int playerStamina = 0;
int playerMaxStamina = 0;

// TODO Expensive string build
String get session => '$gameId ${game.playerId} ${game.playerUUID}';

