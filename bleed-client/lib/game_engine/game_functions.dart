import 'engine_state.dart';

int millisecondsSince(DateTime value) {
  return durationSince(value).inMilliseconds;
}

Duration durationSince(DateTime value) {
  return DateTime.now().difference(value);
}

double convertScreenToWorldX(double value) {
  return (cameraX / zoom) + (value / zoom);
}

double convertScreenToWorldY(double value) {
  return (cameraY / (1.0 / zoom)) + (value / zoom);
}

double get convertScreenToWorldDistance => 1 / zoom;

double convertWorldToScreenX(double value) {
  return (value * zoom) - (cameraX * zoom);
}

double convertWorldToScreenY(double value) {
  return (value * zoom) - (cameraY * zoom);
}

