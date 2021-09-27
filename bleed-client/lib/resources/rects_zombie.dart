import 'dart:ui';

const int _zombieFrameWidth = 36;
const int _zombieFrameHeight = 35;

class RectsZombie {
  final _Idle idle = _Idle();
  final _Walking walking = _Walking();
  final _Dead dead = _Dead();
  final _Striking striking = _Striking();
}

class _Idle {
  final Rect downLeft = _frame(1);
  final Rect left = _frame(2);
  final Rect upLeft = _frame(3);
  final Rect up = _frame(4);
  final Rect upRight = _frame(1);
  final Rect right = _frame(2);
  final Rect downRight = _frame(3);
  final Rect down = _frame(4);
}

class _Dead {
  final Rect downLeft = _frame(29);
  final Rect left = _frame(30);
  final Rect upLeft = _frame(31);
  final Rect up = _frame(32);
  final Rect upRight = _frame(29);
  final Rect right = _frame(30);
  final Rect downRight = _frame(31);
  final Rect down = _frame(32);
}

class _Walking {
  List<Rect> up = [
    _frame(14),
    _frame(15),
    _frame(16),
    _frame(15),
  ];

  List<Rect> upRight = [
    _frame(17),
    _frame(18),
    _frame(19),
    _frame(18),
  ];

  List<Rect> right = [
    _frame(20),
    _frame(21),
    _frame(22),
    _frame(21),
  ];

  List<Rect> downRight = [
    _frame(23),
    _frame(24),
    _frame(25),
    _frame(24),
  ];

  List<Rect> down = [
    _frame(26),
    _frame(27),
    _frame(28),
    _frame(27),
  ];

  List<Rect> downLeft = [
    _frame(5),
    _frame(6),
    _frame(7),
    _frame(6),
  ];

  List<Rect> left = [
    _frame(8),
    _frame(9),
    _frame(10),
    _frame(9),
  ];

  List<Rect> upLeft = [
    _frame(11),
    _frame(12),
    _frame(13),
    _frame(12),
  ];
}

class _Striking {
  List<Rect> up = [
    _frame(4),
    _frame(36),
    _frame(4),
  ];

  List<Rect> upRight = [
    _frame(1),
    _frame(37),
    _frame(1),
  ];

  List<Rect> right = [
    _frame(2),
    _frame(38),
    _frame(2),
  ];

  List<Rect> downRight = [
    _frame(3),
    _frame(39),
    _frame(3),
  ];

  List<Rect> down = [
    _frame(4),
    _frame(40),
    _frame(4),
  ];

  List<Rect> downLeft = [
    _frame(1),
    _frame(33),
    _frame(1),
  ];

  List<Rect> left = [
    _frame(2),
    _frame(34),
    _frame(2),
  ];

  List<Rect> upLeft = [
    _frame(3),
    _frame(35),
    _frame(3),
  ];
}


Rect _frame(int index) {
  return Rect.fromLTWH(((index - 1) * _zombieFrameWidth).toDouble(), 0.0,
      _zombieFrameWidth.toDouble(), _zombieFrameHeight.toDouble());
}
