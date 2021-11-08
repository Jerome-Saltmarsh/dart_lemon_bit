import 'dart:ui';

import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/zoom.dart';

void onMouseScroll(double amount) {
  Offset center1 = screenCenterWorld;
  zoom -= amount * settings.zoomSpeed;
  if (zoom < settings.maxZoom) zoom = settings.maxZoom;
  cameraCenter(center1.dx, center1.dy);
}