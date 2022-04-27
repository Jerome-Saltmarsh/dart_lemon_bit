

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_math/library.dart';

import 'tips.dart';

final hud = _Hud();

class _Hud {
  final state = _State();
  final textEditingControllers = _TextEditingControllers();
  final properties = _Properties();
}

extension HudProperties on _Hud {
  bool get textBoxFocused => modules.game.state.textFieldMessage.hasFocus;
  String get currentTip => tips[hud.state.tipIndex];
  bool get textFieldFocused => modules.game.state.textFieldMessage.hasPrimaryFocus;
}

class _State {
  var tipIndex = 0;
  var observeMode = false;
  var showServers = false;
  var expandScore = false;
}

class _Properties {
  double iconSize = 45;
  Border border = Border.all(color: Colors.black, width: 5.0, style: BorderStyle.solid);
}

class _TextEditingControllers {
  final TextEditingController playerName = TextEditingController();
}

class Ring {
  List<Offset> points = [];
  double sides;

  Ring(this.sides, {double radius = 12}) {
    double radianPerSide = pi2 / sides;
    for (int side = 0; side <= sides; side++) {
      double radians = side * radianPerSide;
      points.add(Offset(cos(radians) * radius, sin(radians) * radius));
    }
  }
}



