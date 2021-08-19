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
    Offset screenCenter1 = screenCenterWorld;
    zoom -= amount * settings.zoomSpeed;
    if (zoom < settings.maxZoom) zoom = settings.maxZoom;
    cameraCenter(screenCenter1.dx, screenCenter1.dy);
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
