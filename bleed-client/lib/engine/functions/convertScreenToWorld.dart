import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/engine/state/zoom.dart';

double convertScreenToWorldX(double value) {
  return cameraX + value / zoom;
}

double convertScreenToWorldY(double value) {
  return cameraY + value / zoom;
}
