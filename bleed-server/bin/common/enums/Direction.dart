const directionUpIndex = 0;
const directionUpRightIndex = 1;
const directionRightIndex = 2;
const directionDownRightIndex = 3;
const directionDownIndex = 4;
const directionDownLeftIndex = 5;
const directionLeftIndex = 6;
const directionUpLeftIndex = 7;

int sanitizeDirectionIndex(int index){
  return index >= 0 ? index % 8 : 8 - (index.abs() % 8);
}

int convertAngleToDirection(double angle) {
  return convertAngleToDirectionInt(angle);
}

int convertAngleToDirectionInt(double angle){
  const piQuarter = 0.78539816339;
  return _fixAngle(angle) ~/ piQuarter;
}

double _fixAngle(double angle){
  const pi2 = 6.28318530718;
  if (angle < 0) {
    angle = (pi2 + angle).abs() % pi2;
  }
  return angle % pi2;
}
