import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/zoom.dart';

double convertScreenToWorldX(double value) {
  return camera.x + value / zoom;
}

double convertScreenToWorldY(double value) {
  return camera.y + value / zoom;
}
