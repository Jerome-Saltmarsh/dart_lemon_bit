import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/update.dart';
import 'package:flutter/material.dart';

import 'connection.dart';
import 'editor/editor.dart';
import 'functions/clearState.dart';
import 'functions/drawCanvas.dart';
import 'images.dart';
import 'instances/game.dart';
import 'instances/settings.dart';
import 'rects.dart';
import 'ui.dart';
import 'utils.dart';

class BleedWidget extends GameWidget {
  @override
  bool uiVisible() => true;

  @override
  void onMouseScroll(double amount) {
    Offset center1 = screenCenterWorld;
    zoom -= amount * settings.zoomSpeed;
    if (zoom < settings.maxZoom) zoom = settings.maxZoom;
    cameraCenter(center1.dx, center1.dy);
    // Offset center2 = screenCenterWorld;
    // Offset diff = center1 - center2;
    // double mag1 = magnitude(diff.dx, diff.dy);
    // cameraX += diff.dx;
    // cameraY += diff.dy;
    // Offset center3 = screenCenterWorld;
    // Offset diff2 = center1 - center3;
    // double mag2 = magnitude(diff2.dx, diff2.dy);
    // if(mag2 > mag1){
    //   print('diff 1: $mag1, diff 2: $mag2');
    // }


    // cameraX += diff2.dx;
    // cameraY += diff2.dy;
    // double a = diff2.dx;

    // for(int i = 0; i < 5; i++){
    //   Offset center2 = screenCenterWorld;
    //   Offset diff = center1 - center2;
    //   cameraX += diff.dx;
    //   cameraY += diff.dy;
    // }
  }

  @override
  Widget buildUI(BuildContext bc) {
    globalContext = bc;
    return buildGameUI(bc);
  }

  @override
  Future init() async {
    await loadImages();
    initAudioPlayers();
    initBleed();
    loadRects();
    initEditor();
    // todo move this
    periodic(checkBulletHoles, ms: 500);
    periodic(redrawUI, seconds: 1);

    // TODO this job is expensive, use reaction instead
    periodic(() {
      if (!connected) {
        redrawGame();
        redrawUI();
      }
    }, ms: 100);

    onConnectedController.stream.listen((event) {
    });

    onDisconnected.stream.listen((event) {
      clearState();
    });

    initUI();
  }

  // TODO move this
  void checkBulletHoles() {
    if (game.bulletHoles.length > 4) {
      game.bulletHoles.removeAt(0);
      game.bulletHoles.removeAt(0);
    }
  }

  @override
  void fixedUpdate() {
    update();
  }

  @override
  void onMouseClick() {}

  @override
  void draw(Canvas canvass, Size _size) {
    drawCanvas(canvass, _size);
  }

  @override
  int targetFPS() {
    return 60;
  }

  @override
  void drawForeground(Canvas canvas, Size size) {
  }
}
