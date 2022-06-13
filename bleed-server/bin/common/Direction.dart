import 'dart:math';

class Direction {
  static const North_East = 0;
  static const East = 1;
  static const South_East = 2;
  static const South = 3;
  static const South_West = 4;
  static const West = 5;
  static const North_West = 6;
  static const North = 7;

  
  static String getName(int value){
    assert (value >= 0);
    assert (value <= 7);

    return const <int, String> {
       North: "North",
       North_East: "North-East",
       East: "East",
       South_East: "South-East",
       South: "South",
       South_West: "South-West",
       West: "West",
       North_West: "North-West",
    }[value] ?? "?";
  }
}

int sanitizeDirectionIndex(int index){
  return index >= 0 ? index % 8 : 8 - (index.abs() % 8);
}

int convertAngleToDirection(double angle) {
  const piQuarter = pi * 0.25;
  return clampAngle(angle) ~/ piQuarter;
}

double clampAngle(double angle){
  const pi2 = pi * 2;
  if (angle < 0) {
    angle = pi2 - (-angle % pi2);
  }
  return angle % pi2;
}
