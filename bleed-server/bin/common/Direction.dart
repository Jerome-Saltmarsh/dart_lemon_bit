import 'dart:math';

import 'package:lemon_math/constants/pi_quarter.dart';
import 'package:lemon_math/functions/clamp_angle.dart';
import 'package:lemon_math/library.dart';

class Direction {
  static const North = 0;
  static const North_East = 1;
  static const East = 2;
  static const South_East = 3;
  static const South = 4;
  static const South_West = 5;
  static const West = 6;
  static const North_West = 7;

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

int convertAngleToDirection(double angle) {
  const piEight = pi / 8;
  return clampDirection(clampAngle(angle - piEight) ~/ piQuarter);
}

double convertDirectionToAngle(int direction){
  if (direction == Direction.North) return pi;
  if (direction == Direction.North_East) return pi + piQuarter;
  if (direction == Direction.East) return pi + piHalf;
  if (direction == Direction.South_East) return pi + piHalf + piQuarter;
  if (direction == Direction.South) return 0;
  if (direction == Direction.South_West) return piQuarter;
  if (direction == Direction.West) return piHalf;
  if (direction == Direction.North_West) return piHalf + piQuarter;
  throw Exception("Could not convert direction $direction to angle");
}

int clampDirection(int index){
  return index >= 0 ? index % 8 : 8 - (index.abs() % 8);
}

