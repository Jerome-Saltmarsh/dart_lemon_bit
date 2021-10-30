import 'dart:ui';

import 'package:bleed_client/classes/AnimationRects.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/resources/rects_utils.dart';

// interface
Rect mapCharacterToSrcMan(Weapon weapon, CharacterState state, Direction direction, int frame) {
  switch (state) {
    case CharacterState.Idle:
      return _mapIdleRect(direction, frame);
    case CharacterState.Walking:
      return _mapWalkingRect(direction, frame);
    case CharacterState.Dead:
      return _mapDeadRect(direction, frame);
    case CharacterState.Aiming:
      return _mapAimingRect(direction);
    case CharacterState.Firing:
      return _getRectFiringShotgun(weapon, direction, frame);
    case CharacterState.Striking:
      return _mapStrikingRect(direction, frame);
    case CharacterState.Running:
      return _mapRunningRect(direction, frame);
    case CharacterState.Reloading:
      return _mapReloadingRect(direction, frame);
    case CharacterState.ChangingWeapon:
      return _mapReloadingRect(direction, frame);
  }
  throw Exception("Could not get character sprite rect");
}

Rect mapCharacterToSrcZombie(Weapon weapon, CharacterState state, Direction direction, int frame) {
  switch (state) {
    case CharacterState.Idle:
      return _mapIdleRect(direction, frame);
    case CharacterState.Walking:
      return _mapZombieWalkingRect(direction, frame);
    case CharacterState.Dead:
      return _mapDeadRect(direction, frame);
    case CharacterState.Aiming:
      return _mapAimingRect(direction);
    case CharacterState.Firing:
      return _getRectFiringShotgun(weapon, direction, frame);
    case CharacterState.Striking:
      return _mapStrikingRect(direction, frame);
    case CharacterState.Running:
      return _mapRunningRect(direction, frame);
    case CharacterState.Reloading:
      return _mapReloadingRect(direction, frame);
    case CharacterState.ChangingWeapon:
      return _mapReloadingRect(direction, frame);
  }
  throw Exception("Could not get character sprite rect");
}

// TODO state belongs in state directory
const double _frameWidth = 64;
const double _frameHeight = 64;

final _RectsHuman _human = _RectsHuman();
final _RectsZombie _zombie = _RectsZombie();

Rect _aimingDownLeft = _frame(21);
Rect _aimingLeft = _frame(23);
Rect _aimingUpLeft = _frame(25);
Rect _aimingUp = _frame(27);
Rect _aimingUpRight = _frame(29);
Rect _aimingRight = _frame(31);
Rect _aimingDownRight = _frame(33);
Rect _aimingDown = _frame(35);

Rect _getRectFiringShotgun(Weapon weapon, Direction direction, int frame) {
  return _mapFrame(_human.firingShotgun, direction, frame);
}

Rect _mapStrikingRect(Direction direction, int frame) {
  return _mapFrame(_human.striking, direction, frame);
}

class _RectsZombie {
  final AnimationRects walking = _srcRects4;
}

class _RectsHuman {
  final AnimationRects idle = _srcRects1;
  final AnimationRects firingShotgun = _srcRects1;
  final AnimationRects changing = _srcRects2;
  final AnimationRects striking = _srcRects2;
  final AnimationRects dying = _srcRects2;
  final AnimationRects walking = _srcRects4;
  final AnimationRects running = _srcRects4;
}

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

Rect _mapWalkingRect(Direction direction, int frame) {
  return _mapFrame(_human.walking, direction, frame);
}

Rect _mapZombieWalkingRect(Direction direction, int frame) {
  return _mapFrame(_zombie.walking, direction, frame);
}


Rect _mapReloadingRect(Direction direction, int frame) {
  switch (direction) {
    case Direction.Down:
      return getFrameLoop(_human.changing.down, frame);
    case Direction.DownRight:
      return getFrameLoop(_human.changing.downRight, frame);
    case Direction.Right:
      return getFrameLoop(_human.changing.right, frame);
    case Direction.UpRight:
      return getFrameLoop(_human.changing.upRight, frame);
    case Direction.Up:
      return getFrameLoop(_human.changing.up, frame);
    case Direction.UpLeft:
      return getFrameLoop(_human.changing.upLeft, frame);
    case Direction.Left:
      return getFrameLoop(_human.changing.left, frame);
    case Direction.DownLeft:
      return getFrameLoop(_human.changing.downLeft, frame);
  }
  throw Exception("Could not get character reloading sprite rect");
}

Rect _mapRunningRect(Direction direction, int frame) {
  return _mapFrame(_human.running, direction, frame);
}

Rect _mapFrame(AnimationRects src, Direction direction, int frame){
  switch (direction) {
    case Direction.Up:
      return getFrameLoop(src.up, frame);
    case Direction.UpRight:
      return getFrameLoop(src.upRight, frame);
    case Direction.Right:
      return getFrameLoop(src.right, frame);
    case Direction.DownRight:
      return getFrameLoop(src.downRight, frame);
    case Direction.Down:
      return getFrameLoop(src.down, frame);
    case Direction.DownLeft:
      return getFrameLoop(src.downLeft, frame);
    case Direction.Left:
      return getFrameLoop(src.left, frame);
    case Direction.UpLeft:
      return getFrameLoop(src.upLeft, frame);
  }
}

Rect _mapIdleRect(Direction direction, int frame) {
  return _mapFrame(_human.idle, direction, frame);
}

Rect _mapDeadRect(Direction direction, int frame) {
  return _mapFrame(_human.dying, direction, frame);
}

Rect _mapAimingRect(Direction direction) {
  switch (direction) {
    case Direction.Up:
      return _aimingUp;
    case Direction.UpRight:
      return _aimingUpRight;
    case Direction.Right:
      return _aimingRight;
    case Direction.DownRight:
      return _aimingDownRight;
    case Direction.Down:
      return _aimingDown;
    case Direction.DownLeft:
      return _aimingDownLeft;
    case Direction.Left:
      return _aimingLeft;
    case Direction.UpLeft:
      return _aimingUpLeft;
  }
  throw Exception("Could not get character dead sprite rect");
}
