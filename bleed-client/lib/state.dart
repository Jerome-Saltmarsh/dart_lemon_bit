import 'dart:ui';

import 'package:flutter/material.dart';
import 'classes/Particle.dart';
import 'classes/SpriteAnimation.dart';
import '../common.dart';
import '../constants.dart';
import 'enums.dart';

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
bool smooth = false;
BuildContext context;
List<List<dynamic>> players = [];
List<List<dynamic>> npcs = [];
List<List<dynamic>> bullets = [];
List<double> bulletHoles = [];
List<Particle> particles = [];
List<double> grenades = [];
List<SpriteAnimation> animations = [];
int drawFrame = 0;
bool debugMode = false;
int playerId = idNotConnected;
dynamic player;
String playerUUID = "";
int serverFramesMS = 0;
int actualFPS;
double playerHealth = 0;
double playerMaxHealth = 0;
List<RSTransform> playersTransforms = [];
List<Rect> playersRects = [];
List<RSTransform> npcsTransforms = [];
List<Rect> particleRects = [];
List<RSTransform> particleTransforms = [];
List<Rect> npcsRects = [];
int tilesX = 0;
int tilesY = 0;
List<List<Tile>> tiles = [];
List<RSTransform> tileTransforms = [];
List<Rect> tileRects = [];
Map<int, bool> gameEvents = Map();

int handgunRounds = 0;
int handgunClipSize = 0;
int handgunClips = 0;
int handgunMaxClips = 0;

