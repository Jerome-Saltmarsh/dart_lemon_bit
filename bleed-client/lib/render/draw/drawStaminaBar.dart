import 'dart:ui';

import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/paint.dart';

void drawStaminaBar(Canvas canvas) {
  double percentage = player.stamina / player.staminaMax;

  paint.color = Colors.white;

  canvas.drawRect(
      Rect.fromLTWH(screenCenterX - 50, 25, 100, 15), paint);

  paint.color = colours.orange;
  canvas.drawRect(Rect.fromLTWH(screenCenterX - 50, 25, 100 * percentage, 15),
      paint);
}