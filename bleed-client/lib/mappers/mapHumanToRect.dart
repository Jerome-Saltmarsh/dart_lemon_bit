import 'dart:ui';

import 'package:bleed_client/classes/AnimationRects.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/constants/defaultSpriteFrameRate.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/resources/rects_utils.dart';

// interface
Rect mapCharacterToSrcMan(Weapon weapon, CharacterState state, Direction direction, int frame) {
  switch (state) {
    case CharacterState.Idle:
      return _mapFrameLoop(_srcRects1, direction, frame);
    case CharacterState.Walking:
      return _mapFrameLoop(_srcRects4, direction, frame);
    case CharacterState.Dead:
      return _mapFrame(_srcRects2, direction, frame);
    case CharacterState.Aiming:
      return _mapFrame(_srcRects1, direction, frame);
    case CharacterState.Firing:
      return _mapFrame(_srcRects1, direction, frame);
    case CharacterState.Striking:
      return _mapFrame(_srcRects2, direction, frame);
    case CharacterState.Running:
      return _mapFrameLoop(_srcRects4, direction, frame, frameRate: 4);
    case CharacterState.Reloading:
      return _mapFrame(_srcRects2, direction, frame);
    case CharacterState.ChangingWeapon:
      return _mapFrame(_srcRects2, direction, frame);
  }
  throw Exception("Could not get character sprite rect");
}

Rect mapCharacterToSrcZombie(Weapon weapon, CharacterState state, Direction direction, int frame) {
  switch (state) {
    case CharacterState.Idle:
      return _mapFrameLoop(_srcRects1, direction, frame);
    case CharacterState.Walking:
      return _mapFrameLoop(_srcRects4, direction, frame);
    case CharacterState.Dead:
      return _mapFrame(_srcRects2, direction, frame);
    case CharacterState.Striking:
      return _mapFrame(_srcRects2, direction, frame);
    case CharacterState.Running:
      return _mapFrameLoop(_srcRects4, direction, frame);
    default:
      throw Exception("Could not get character sprite rect");
  }
}

// TODO state belongs in state directory
const double _frameWidth = 64;
const double _frameHeight = 64;

final AnimationRects _srcRects1 = AnimationRects(
    down: _frames([1]),
    downRight: _frames([2]),
    right:  _frames([3]),
    upRight: _frames([4]),
    up:  _frames([5]),
    upLeft: _frames([6]),
    left:  _frames([7]),
    downLeft: _frames([8])
);

final AnimationRects _srcRects2 = AnimationRects(
    down: _frames([1, 2]),
    downRight: _frames([3, 4]),
    right:  _frames([5, 6]),
    upRight: _frames([7, 8]),
    up:  _frames([9, 10]),
    upLeft: _frames([11, 12]),
    left:  _frames([13, 14]),
    downLeft: _frames([15, 16])
);

final AnimationRects _srcRects4 = AnimationRects(
    down: _frames([1, 2, 3, 4]),
    downRight: _frames([5, 6, 7, 8]),
    right:  _frames([9, 10, 11, 12]),
    upRight: _frames([13, 14, 15, 16]),
    up:  _frames([17, 18, 19, 20]),
    upLeft: _frames([21, 22, 23, 24]),
    left:  _frames([25, 26, 27, 28]),
    downLeft: _frames([29, 30, 31, 32])
);

List<Rect> _frames(List<int> indexes) {
  List<Rect> rects = [];
  for (int i in indexes) {
    rects.add(_frame(i));
  }
  return rects;
}

Rect _frame(int index) {
  return Rect.fromLTWH(
      (index - 1) * _frameWidth,
      0.0,
      _frameWidth,
      _frameHeight);
}

Rect _mapFrameLoop(AnimationRects src, Direction direction, int frame, {int frameRate = defaultSpriteFrameRate}){
  switch (direction) {
    case Direction.Up:
      return getFrameLoop(src.up, frame, frameRate: frameRate);
    case Direction.UpRight:
      return getFrameLoop(src.upRight, frame, frameRate: frameRate);
    case Direction.Right:
      return getFrameLoop(src.right, frame, frameRate: frameRate);
    case Direction.DownRight:
      return getFrameLoop(src.downRight, frame, frameRate: frameRate);
    case Direction.Down:
      return getFrameLoop(src.down, frame, frameRate: frameRate);
    case Direction.DownLeft:
      return getFrameLoop(src.downLeft, frame, frameRate: frameRate);
    case Direction.Left:
      return getFrameLoop(src.left, frame, frameRate: frameRate);
    case Direction.UpLeft:
      return getFrameLoop(src.upLeft, frame, frameRate: frameRate);
    default:
      throw Exception("Should never happen");
  }
}

Rect _mapFrame(AnimationRects src, Direction direction, int frame){
  switch (direction) {
    case Direction.Up:
      return getFrame(src.up, frame);
    case Direction.UpRight:
      return getFrame(src.upRight, frame);
    case Direction.Right:
      return getFrame(src.right, frame);
    case Direction.DownRight:
      return getFrame(src.downRight, frame);
    case Direction.Down:
      return getFrame(src.down, frame);
    case Direction.DownLeft:
      return getFrame(src.downLeft, frame);
    case Direction.Left:
      return getFrame(src.left, frame);
    case Direction.UpLeft:
      return getFrame(src.upLeft, frame);
    default:
      throw Exception("Could not map frame");
  }
}

