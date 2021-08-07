import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/game_engine/game_widget.dart';

import 'connection.dart';
import 'functions/clearState.dart';
import 'functions/drawCanvas.dart';
import 'images.dart';
import 'rects.dart';
import 'send.dart';
import 'state.dart';
import 'ui.dart';
import 'utils.dart';

class BleedWidget extends GameWidget {
  @override
  bool uiVisible() => true;

  @override
  Widget buildUI(BuildContext bc) {
    context = bc;
    return buildGameUI(context);
  }

  @override
  Future init() async {
    await loadImages();
    loadRects();
    periodic(checkBulletHoles, ms: 500);
    periodic(redrawUI, seconds: 1);

    periodic(() {
      if (!connected) {
        forceRedraw();
      }
    }, ms: 100);

    onConnectedController.stream.listen((event) {
      sendRequestTiles();
      sendRequestSpawn();
      redrawUI();
    });

    onDisconnected.stream.listen((event) {
      clearState();
    });

    initUI();
  }

  void checkBulletHoles() {
    if (bulletHoles.length > 4) {
      bulletHoles.removeAt(0);
      bulletHoles.removeAt(0);
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
}
