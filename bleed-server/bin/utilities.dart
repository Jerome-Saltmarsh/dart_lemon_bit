import 'classes/character.dart';

double clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

int clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

// TODO floating logic
void setAngle(Character character, double value) {
  if (character.deadOrBusy) return;
  character.angle = value;
}

void faceAimDirection(Character character) {
  setAngle(character, character.angle);
}

int calculateTime({int minute = 0, int hour = 0}){
  const secondsPerMinute = 60;
  const minutesPerHour = 60;
  return secondsPerMinute * minutesPerHour * hour + minute;
}


