import 'dart:math';

import '../input_type.dart';

class IsometricDirection {
  static const North = 0;
  static const North_East = 1;
  static const East = 2;
  static const South_East = 3;
  static const South = 4;
  static const South_West = 5;
  static const West = 6;
  static const North_West = 7;
  static const None = 8;

  static int fromInputDirection(int inputDirection){
    return const {
      InputDirection.Up         : IsometricDirection.North_East,
      InputDirection.Up_Right   : IsometricDirection.East,
      InputDirection.Right      : IsometricDirection.South_East,
      InputDirection.Down_Right : IsometricDirection.South,
      InputDirection.Down       : IsometricDirection.South_West,
      InputDirection.Down_Left  : IsometricDirection.West,
      InputDirection.Left       : IsometricDirection.North_West,
      InputDirection.Up_Left    : IsometricDirection.North,
      InputDirection.None       : IsometricDirection.None,
    }[inputDirection] ?? IsometricDirection.None;
  }

  /// 7 and 1
  /// the difference is actually only 2
  ///
  static int getDifference(int a, int b){
    final diff = (a - b).abs();
    if (diff < 4) {
      if (a < b){
        return -diff;
      }
      return diff;
    }
    const totalDirections = 8;
    final diff2 = totalDirections - diff;

    if (a > b){
       return -diff2;
    }
    return diff2;
  }

  static String getName(int value){
    assert (value >= 0);
    assert (value <= 8);
    return const <int, String> {
       North: 'North',
       North_East: 'North-East',
       East: 'East',
       South_East: 'South-East',
       South: 'South',
       South_West: 'South-West',
       West: 'West',
       North_West: 'North-West',
       None: 'None',
    }[value] ?? '?';
  }

  static double toRadian(int direction){
    const piQuarter = pi / 4;
    const piHalf = pi / 2;
    if (direction == IsometricDirection.North) return pi;
    if (direction == IsometricDirection.North_East) return pi + piQuarter;
    if (direction == IsometricDirection.East) return pi + piHalf;
    if (direction == IsometricDirection.South_East) return pi + piHalf + piQuarter;
    if (direction == IsometricDirection.South) return 0;
    if (direction == IsometricDirection.South_West) return piQuarter;
    if (direction == IsometricDirection.West) return piHalf;
    if (direction == IsometricDirection.North_West) return piHalf + piQuarter;
    throw Exception('Could not convert direction $direction to angle');
  }

  static int fromRadian(double angle) {
    const piQuarter = pi / 4;
    if (angle < piQuarter * 1) return South;
    if (angle < piQuarter * 2) return South_West;
    if (angle < piQuarter * 3) return West;
    if (angle < piQuarter * 4) return North_West;
    if (angle < piQuarter * 5) return North;
    if (angle < piQuarter * 6) return North_East;
    if (angle < piQuarter * 7) return East;
    return South_East;
  }

  static int convertToVelocityColumn(int direction) => <int, int> {
    North: -1,
    North_East: -1,
    East: 0,
    South_East: 1,
    South: 1,
    South_West: 1,
    West: 0,
    North_West: -1,
  }[direction] ?? (throw Exception('IsometricDirection.convertToColumnVelocity2($direction)'));

  static int convertToVelocityRow(int direction) => <int, int> {
        North: 0,
        North_East: 1,
        East: 1,
        South_East: 1,
        South: 0,
        South_West: -1,
        West: -1,
        North_West: -1,
  }[direction] ??
      (throw Exception('IsometricDirection.convertToVelocityRow($direction)'));
}


