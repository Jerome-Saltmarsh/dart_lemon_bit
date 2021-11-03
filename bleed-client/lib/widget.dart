import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/buildContext.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/functions/update.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'engine/properties/mouseWorld.dart';
import 'engine/state/camera.dart';
import 'images.dart';
import 'render/drawCanvas.dart';
import 'state/settings.dart';
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
    canvass.scale(zoom, zoom);
    canvass.translate(-camera.x, -camera.y);
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
    if (game.gameId < 0) return;

    double aimX = mouseWorldX;
    double aimY = mouseWorldY;
    bool aiming = false;
    for (int i = 0; i < game.totalZombies; i++) {
      if (diff(aimX, game.zombies[i].x) < 6 &&
          diff(aimY, game.zombies[i].y) < 6) {
        aiming = true;
        break;
      }
    }

    // if (player.alive) {
    //   _drawStaminaBar(canvas);
    // }

    // _drawMouseAim(aiming);
  }

  Ring ammoRing = Ring(32, radius: 8);

  void _drawMouseAim(bool aiming) {
    if (!mouseAvailable) return;
    if (player.equippedRounds == 0) return;

    double p = player.equippedRounds / getMaxRounds(game.playerWeapon);

    drawRing(ammoRing,
        percentage: p,
        color: Colors.blue,
        position: Offset(mouseX, mouseY),
        backgroundColor: aiming ? Colors.red : Colors.white);
    return;
  }

  void _drawStaminaBar(Canvas canvas) {
    double percentage = player.stamina / player.staminaMax;

    paint.color = Colors.white;

    canvas.drawRect(
        Rect.fromLTWH(screenCenterX - 50, 25, 100, 15), paint);

    paint.color = colours.orange;
    canvas.drawRect(Rect.fromLTWH(screenCenterX - 50, 25, 100 * percentage, 15),
        paint);
  }
}
