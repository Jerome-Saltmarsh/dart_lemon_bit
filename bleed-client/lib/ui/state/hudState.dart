

import 'dart:math';

import 'package:bleed_client/ui/logic/toggle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:lemon_math/pi2.dart';
import 'package:lemon_watch/watch.dart';

import 'tips.dart';


// properties
bool get textFieldFocused => hud.focusNodes.textFieldMessage.hasPrimaryFocus;
String get currentTip => tips[hud.state.tipIndex];

final _Hud hud = _Hud();

class Bool extends Watch<bool> {
  Bool(bool value) : super(value);

  void toggle(){
    this.value = !value;
  }

  void setTrue(){
    value = true;
  }

  void setFalse(){
    value = false;
  }
}

class _Hud {
  final Bool skillTreeVisible = Bool(false);
  final _State state = _State();
  final _FocusNodes focusNodes = _FocusNodes();
  final _TextEditingControllers textEditingControllers = _TextEditingControllers();
  final _Properties properties = _Properties();
}


class _State {
  int tipIndex = 0;
  Watch<bool> textBoxVisible = Watch(false);
  bool observeMode = false;
  bool showServers = false;
  bool expandScore = false;
  Watch<bool> menuVisible = Watch(false);
}

class _Properties {
  double iconSize = 45;
  Border border = Border.all(color: Colors.black, width: 5.0, style: BorderStyle.solid);
}

class _TextEditingControllers {
  final TextEditingController speak = TextEditingController();
  final TextEditingController playerName = TextEditingController();
}

class _FocusNodes {
  FocusNode textFieldMessage = FocusNode();
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

