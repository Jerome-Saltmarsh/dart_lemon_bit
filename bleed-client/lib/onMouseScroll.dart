import 'dart:ui';

import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/utils.dart';

void onMouseScroll(double amount) {
  Offset center1 = screenCenterWorld;
  zoom -= amount * settings.zoomSpeed;
  if (zoom < settings.maxZoom) zoom = settings.maxZoom;
  cameraCenter(center1.dx, center1.dy);
}