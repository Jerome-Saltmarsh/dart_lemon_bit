

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/pi2.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'tips.dart';

final _Hud hud = _Hud();

class _Hud {
  final _State state = _State();
  final _TextEditingControllers textEditingControllers = _TextEditingControllers();
  final _Properties properties = _Properties();
}

extension HudProperties on _Hud {
  bool get textBoxFocused => modules.game.state.textFieldMessage.hasFocus;
  String get currentTip => tips[hud.state.tipIndex];
  bool get textFieldFocused => modules.game.state.textFieldMessage.hasPrimaryFocus;
}


final Widget fps = WatchBuilder(engine.fps, (int fps){
  return text("fps $fps");
});

class _State {
  int tipIndex = 0;
  bool observeMode = false;
  bool showServers = false;
  bool expandScore = false;
}

class _Properties {
  double iconSize = 45;
  Border border = Border.all(color: Colors.black, width: 5.0, style: BorderStyle.solid);
}

class _TextEditingControllers {
  // final TextEditingController speak = TextEditingController();
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



