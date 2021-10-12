import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/audio.dart';
import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/ui/dialogs.dart';
import 'package:bleed_client/update.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'connection.dart';
import 'editor/editor.dart';
import 'functions/clearState.dart';
import 'functions/drawCanvas.dart';
import 'functions/drawParticle.dart';
import 'game_engine/global_paint.dart';
import 'images.dart';
import 'input.dart';
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
    try {
      return buildGameUI(bc);
    } catch (error) {
      if (settings.developMode) {
        return Text("An error occurred");
      }
      return Container();
    }
  }

  @override
  Future init() async {
    await images.load();
    initAudioPlayers();
    initBleed();
    loadRects();
    initEditor();
    initInput();

    compiledGame.zombies.clear();
    for (int i = 0; i < 5000; i++) {
      compiledGame.zombies.add(Zombie(x: 0, y: 0, state: CharacterState.Idle, scoreMultiplier: ""));
    }

    compiledGame.npcs = [];
    for (int i = 0; i < 200; i++) {
      compiledGame.npcs.add([0, 0, 0.0, 0.0, 0, 0]);
    }

    compiledGame.players = [];
    for (int i = 0; i < 1000; i++) {
      compiledGame.players.add([0, 0, 0.0, 0.0, 0, 0, 0, ""]);
    }

    onDisconnected.stream.listen((event) {
      showDialogConnectFailed();
      clearState();
    });

    onDone.stream.listen((event) {
      clearState();
      rebuildUI();
      redrawCanvas();
    });

    initUI();
    rebuildUI();
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
    if (!connected) return;
    if (state.compiledGame.gameId < 0) return;

    double aimX = mouseWorldX;
    double aimY = mouseWorldY;
    bool aiming = false;
    for (int i = 0; i < compiledGame.totalZombies; i++) {
      if (diff(aimX, compiledGame.zombies[i].x) < 6 &&
          diff(aimY, compiledGame.zombies[i].y) < 6) {
        aiming = true;
        break;
      }
    }

    if (player.alive) {
      _drawStaminaBar(canvas);
    }

    _drawMouseAim(aiming);
  }

  Ring ammoRing = Ring(32, radius: 8);

  void _drawMouseAim(bool aiming) {
    if (!mouseAvailable) return;
    if (player.equippedRounds == 0) return;

    double p = player.equippedRounds / getMaxRounds(compiledGame.playerWeapon);

    drawRing(ammoRing,
        percentage: p,
        color: Colors.blue,
        position: Offset(mouseX, mouseY),
        backgroundColor: aiming ? Colors.red : Colors.white);
    return;
  }

  void _drawStaminaBar(Canvas canvas) {
    double percentage = player.stamina / player.staminaMax;

    globalPaint.color = Colors.white;

    canvas.drawRect(
        Rect.fromLTWH(screenCenterX - 50, 25, 100, 15), globalPaint);

    globalPaint.color = orange;
    canvas.drawRect(Rect.fromLTWH(screenCenterX - 50, 25, 100 * percentage, 15),
        globalPaint);
  }
}
