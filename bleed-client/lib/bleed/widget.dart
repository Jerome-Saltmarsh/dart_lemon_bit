import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_game_engine/bleed/update.dart';
import 'package:flutter_game_engine/bleed/utils.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'connection.dart';
import 'draw.dart';
import 'resources.dart';
import 'state.dart';
import 'ui.dart';

class BleedWidget extends GameWidget {

  @override
  bool uiVisible() => true;

  @override
  Widget buildUI(BuildContext bc) {
    context = bc;
    return buildDebugUI(context);
  }

  @override
  Future init() async {
    loadResources();
    // connect();
    // sendRequestSpawn();
    periodic(checkBulletHoles, ms: 500);
  }

  void checkBulletHoles(){
    if (bulletHoles.length > 4){
      bulletHoles.removeAt(0);
      bulletHoles.removeAt(0);
    }
  }

  @override
  void fixedUpdate() {
    update();
  }

  @override
  void onMouseClick() {

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
