import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/update.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'connection.dart';
import 'editor/editor.dart';
import 'functions/clearState.dart';
import 'functions/drawCanvas.dart';
import 'game_engine/engine_draw.dart';
import 'images.dart';
import 'instances/settings.dart';
import 'keys.dart';
import 'rects.dart';
import 'ui.dart';
import 'utils.dart';

class BleedWidget extends GameWidget {
  @override
  bool uiVisible() => true;

  @override
  void onMouseScroll(double amount) {
    // TODO logic does not belong here
    Offset center1 = screenCenterWorld;
    zoom -= amount * settings.zoomSpeed;
    if (zoom < settings.maxZoom) zoom = settings.maxZoom;
    cameraCenter(center1.dx, center1.dy);
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
    startJobs();

    compiledGame.npcs = [];
    for (int i = 0; i < 5000; i++) {
      compiledGame.npcs.add([0, 0, 0.0, 0.0, 0, 0]);
    }

    compiledGame.players = [];
    for(int i = 0; i < 1000; i++){
      compiledGame.players.add([0, 0, 0.0, 0.0, 0, 0, 0, ""]);
    }

    onDisconnected.stream.listen((event) {
      showDialogConnectFailed();
      clearState();
    });

    initUI();
  }

  void startJobs() {
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
  }

  // TODO move this
  void checkBulletHoles() {
    if (compiledGame.bulletHoles.length > 4) {
      compiledGame.bulletHoles.removeAt(0);
      compiledGame.bulletHoles.removeAt(0);
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
    if (!mouseAvailable) return;
    if (state.compiledGame.gameId < 0) return;


    double aimX = mouseWorldX;
    double aimY = mouseWorldY;
    bool aiming = false;
    for (int i = 0; i < compiledGame.npcs.length; i++) {
      if (diff(aimX, compiledGame.npcs[i][x]) < 6 &&
          diff(aimY, compiledGame.npcs[i][y]) < 5) {
        aiming = true;
        break;
      }
    }

    if (player.stamina < player.staminaMax) {
      double percentage = player.stamina / player.staminaMax;

      globalPaint.color = Colors.white;

      canvas.drawRect(
          Rect.fromLTWH(screenCenterX - 50, 25, 100, 15), globalPaint);

      globalPaint.color = Colors.yellow;
      canvas.drawRect(
          Rect.fromLTWH(screenCenterX - 50, 25, 100 * percentage, 15),
          globalPaint);
    }

    drawCircleOutline(
        radius: 6,
        x: mouseX,
        y: mouseY,
        color: aiming ? Colors.red : Colors.white);

    drawText(player.equippedRounds.toString(), mouseX + 10, mouseY - 35);

    globalPaint.color = Colors.white;
    for (int i = 0; i < player.equippedClips; i++) {
      globalCanvas.drawRect(
          Rect.fromLTWH(mouseX + 35 + (i * 9), mouseY - 33, 7, 17),
          globalPaint);
    }
  }
}
