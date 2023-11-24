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

  static int fromInputDirection(int inputDirection) => const {
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

  static int toInputDirection(int isometricDirection) => const {
      IsometricDirection.North_East : InputDirection.Up,
      IsometricDirection.East : InputDirection.Up_Right,
      IsometricDirection.South_East : InputDirection.Right,
      IsometricDirection.South : InputDirection.Down_Right,
      IsometricDirection.South_West : InputDirection.Down,
      IsometricDirection.West : InputDirection.Down_Left,
      IsometricDirection.North_West : InputDirection.Left,
      IsometricDirection.North : InputDirection.Up_Left,
      IsometricDirection.None : InputDirection.None,
    }[isometricDirection] ?? InputDirection.None;

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
    const piQuarters0 = piQuarter * 0;
    const piQuarters1 = piQuarter * 1;
    const piQuarters2 = piQuarter * 2;
    const piQuarters3 = piQuarter * 3;
    const piQuarters4 = piQuarter * 4;
    const piQuarters5 = piQuarter * 5;
    const piQuarters6 = piQuarter * 6;
    const piQuarters7 = piQuarter * 7;

    if (direction == IsometricDirection.South) {
      return piQuarters0;
    }
    if (direction == IsometricDirection.South_West) {
      return piQuarters1;
    }
    if (direction == IsometricDirection.West) {
      return piQuarters2;
    }
    if (direction == IsometricDirection.North_West) {
      return piQuarters3;
    }
    if (direction == IsometricDirection.North) {
      return piQuarters4;
    }
    if (direction == IsometricDirection.North_East) {
      return piQuarters5;
    }
    if (direction == IsometricDirection.East) {
      return piQuarters6;
    }
    if (direction == IsometricDirection.South_East) {
      return piQuarters7;
    }

    throw Exception('Could not convert direction $direction to angle');
  }

  static int fromRadian(double angle) {
    const piQuarter = pi / 4;
    const piEight = pi / 8;
    const piQuarters1 = piQuarter * 1;
    const piQuarters2 = piQuarter * 2;
    const piQuarters3 = piQuarter * 3;
    const piQuarters4 = piQuarter * 4;
    const piQuarters5 = piQuarter * 5;
    const piQuarters6 = piQuarter * 6;
    const piQuarters7 = piQuarter * 7;
    const piQuarters8 = piQuarter * 8;

    if (angle < piQuarters1 - piEight) return South;
    if (angle < piQuarters2 - piEight) return South_West;
    if (angle < piQuarters3 - piEight) return West;
    if (angle < piQuarters4 - piEight) return North_West;
    if (angle < piQuarters5 - piEight) return North;
    if (angle < piQuarters6 - piEight) return North_East;
    if (angle < piQuarters7 - piEight) return East;
    if (angle < piQuarters8 - piEight) return South_East;
    return South;
  }

  static int convertToVelocityRow(int direction) => const <int, int> {
        North: -1,
        North_East: -1,
        East: 0,
        South_East: 1,
        South: 1,
        South_West: 1,
        West: 0,
        North_West: -1,
  }[direction] ??
      (throw Exception('IsometricDirection.convertToVelocityRow($direction)'));

  static int convertToVelocityColumn(int direction) => const  <int, int> {
    North: 0,
    North_East: -1,
    East: -1,
    South_East: -1,
    South: 0,
    South_West: 1,
    West: 1,
    North_West: 1,
  }[direction] ?? (throw Exception('IsometricDirection.convertToColumnVelocity2($direction)'));
}


