import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common.dart';

Size size;
int frameRate = 5;
int frameRateValue = 0;
int packagesSent = 0;
int packagesReceived = 0;
int errors = 0;
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
List<dynamic> players = [];
List<dynamic> npcs = [];
List<dynamic> bullets = [];
int drawFrame = 0;
Canvas canvas;
bool connected = false;
bool debugMode = false;
int id = idNotConnected;
const idNotConnected = -1;

get playerCharacter {
  if(id == idNotConnected) return null;

  return players.firstWhere((element) => element[4] == id, orElse: (){
    return null;
  });
}