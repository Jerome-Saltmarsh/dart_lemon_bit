import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/buildContext.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../images.dart';
import '../../state/settings.dart';
import '../../utils.dart';

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
  void onMouseClick() {}

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
