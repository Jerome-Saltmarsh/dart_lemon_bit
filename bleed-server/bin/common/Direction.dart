import 'dart:math';

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
  static const None = 8;

  static String getName(int value){
    assert (value >= 0);
    assert (value <= 8);
    return const <int, String> {
       North: "North",
       North_East: "North-East",
       East: "East",
       South_East: "South-East",
       South: "South",
       South_West: "South-West",
       West: "West",
       North_West: "North-West",
       None: "None",
    }[value] ?? "?";
  }

  static double toRadian(int direction){
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

  static int fromRadian(double angle) {
    if (angle < piQuarter * 1) return South;
    if (angle < piQuarter * 2) return South_West;
    if (angle < piQuarter * 3) return West;
    if (angle < piQuarter * 4) return North_West;
    if (angle < piQuarter * 5) return North;
    if (angle < piQuarter * 6) return North_East;
    if (angle < piQuarter * 7) return East;
    return South_East;
  }
}



int clampDirection(int index){
  return index >= 0 ? index % 8 : 8 - (index.abs() % 8);
}

