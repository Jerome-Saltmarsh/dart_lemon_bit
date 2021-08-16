import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:flutter/material.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/game_engine/game_widget.dart';

import 'connection.dart';
import 'editor/editor.dart';
import 'functions/clearState.dart';
import 'functions/drawCanvas.dart';
import 'images.dart';
import 'rects.dart';
import 'state.dart';
import 'ui.dart';
import 'utils.dart';

class BleedWidget extends GameWidget {
  @override
  bool uiVisible() => true;

  @override
  void onMouseScroll(double amount) {
    zoom -= amount * 0.0005;
    if (zoom < 0.1) zoom = 0.1;
    print('zoom: $zoom');
  }

  @override
  Widget buildUI(BuildContext bc) {
    context = bc;
    return buildGameUI(context);
  }

  @override
  Future init() async {
    await loadImages();
    loadRects();
    initEditor();
    // todo move this
    periodic(checkBulletHoles, ms: 500);
    periodic(redrawUI, seconds: 1);

    // TODO this job is expensive, use reaction instead
    periodic(() {
      if (!connected) {
        forceRedraw();
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
