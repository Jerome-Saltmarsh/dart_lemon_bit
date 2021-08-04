import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_engine/bleed/update.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'connection.dart';
import 'draw.dart';
import 'resources.dart';
import 'send.dart';
import 'state.dart';
import 'ui.dart';

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
    update();
  }

  @override
  void onMouseClick() {

  }

  @override
  Future init() async {
    loadResources();
    connect();
    sendRequestSpawn();
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

    drawTiles();
    drawPlayerHealth();
    drawBullets();
    drawBulletHoles();
    drawBlood();
    drawParticles();
    drawCharacters();
    drawMouse();
  }
}
