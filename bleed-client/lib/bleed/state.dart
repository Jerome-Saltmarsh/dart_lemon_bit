import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_engine/bleed/enums.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common.dart';
import 'constants.dart';

Size size;
int frameRate = 5;
int frameRateValue = 0;
int packagesSent = 0;
int packagesReceived = 0;
int errors = 0;
int pass = 0;
int serverFrame = 0;
int dones = 0;
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
bool smooth = true;
BuildContext context;
WebSocketChannel webSocketChannel;
List<List<dynamic>> players = [];
List<List<dynamic>> npcs = [];
List<List<dynamic>> bullets = [];
int drawFrame = 0;
Canvas canvas;
bool connected = false;
bool debugMode = false;
int playerId = idNotConnected;
String playerUUID = "";
int serverFramesMS = 0;
int actualFPS;
double playerHealth = 0;
double playerMaxHealth = 0;

List<RSTransform> playersTransforms = [];
List<Rect> playersRects = [];
List<RSTransform> npcsTransforms = [];
List<Rect> npcsRects = [];
bool respawnRequestSent = false;

bool firstPass = true;
bool secondPass = true;
bool thirdPass = true;
bool fourthPass = true;


int tilesX = 0;
int tilesY = 0;
List<List<Tile>> tiles = [];

List<RSTransform> tileTransforms = [];
List<Rect> tileRects = [];


Map<int, bool> bulletEventsFired = Map();
