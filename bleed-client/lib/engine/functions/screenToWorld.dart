import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/zoom.dart';

double screenToWorldX(double value) {
  return camera.x + value / zoom;
}

double screenToWorldY(double value) {
  return camera.y + value / zoom;
}
