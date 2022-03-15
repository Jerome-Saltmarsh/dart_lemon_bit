

import 'dart:math';

import 'package:gamestream_flutter/common/enums/Direction.dart';

const _piQuater = pi * 0.25;
const _piHalf = pi * 0.5;

const Map<Direction, double> mapDirectionToAngle = {
  Direction.Up: 0,
  Direction.UpRight: _piQuater,
  Direction.Right: _piHalf,
  Direction.DownRight: _piHalf + _piQuater,
  Direction.Down : pi,
  Direction.DownLeft: pi + _piQuater,
  Direction.Left: pi + _piHalf,
  Direction.UpLeft: pi + _piHalf + _piQuater,
};

