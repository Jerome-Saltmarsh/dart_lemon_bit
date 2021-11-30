import 'dart:ui';

import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_engine/game.dart';

void onMouseScroll(double amount) {
  Offset center1 = screenCenterWorld;
  targetZoom -= amount * game.settings.zoomSpeed;
  if (targetZoom < game.settings.maxZoom) targetZoom = game.settings.maxZoom;
  cameraCenter(center1.dx, center1.dy);
}