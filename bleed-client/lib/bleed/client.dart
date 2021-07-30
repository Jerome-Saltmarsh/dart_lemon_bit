import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'connection.dart';
import 'draw.dart';
import 'input.dart';
import 'resources.dart';
import 'settings.dart';
import 'state.dart';
import 'ui.dart';
import 'utils.dart';

class BleedClient extends GameWidget {
  @override
  bool uiVisible() => true;

  @override
  Widget buildUI(BuildContext bc) {
    context = bc;
    return buildDebugUI(context);
  }

  @override
  void fixedUpdate() {
    DateTime now = DateTime.now();
    refreshDuration = now.difference(lastRefresh);
    lastRefresh = DateTime.now();
    framesSinceEvent++;
    smoothing();
    controlCamera();
    readPlayerInput();

    if (playerAssigned) {
      sendRequestUpdatePlayer();
    } else {
      sendCommandUpdate();
    }
  }

  @override
  void onMouseClick() {
    sendRequestFire();
  }

  @override
  Future init() async {
    loadResources();
    connect();
    // Timer(Duration(milliseconds: 100), showChangeNameDialog);
    Timer(Duration(seconds: 2), () {
      sendRequestSpawn();
    });
  }

  @override
  void draw(Canvas canvass, Size _size) {
    size = _size;
    canvas = canvass;
    if (!connected) return;

    frameRateValue++;
    if (frameRateValue % frameRate == 0) {
      drawFrame++;
    }

    if (mousePosX != null) {
      drawCircleOutline(
          radius: 5,
          x: mousePosX + cameraX,
          y: mousePosY + cameraY,
          color: white);
    }

    drawTiles();
    drawBullets();
    try {
      drawCharacters();
    } catch (e) {
      print(e);
    }
    // dynamic player = getPlayerCharacter();
    // if (player != null && getState(player) == characterStateAiming) {
    //   double accuracy = player[keyAccuracy];
    //   double l = player[keyAimAngle] - (accuracy * 0.5);
    //   double r = player[keyAimAngle] + (accuracy * 0.5);
    //   drawLineRotation(player, l, bulletRange);
    //   drawLineRotation(player, r, bulletRange);
    // }
  }
}
