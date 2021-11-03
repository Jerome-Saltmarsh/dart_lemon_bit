

import 'dart:math';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Score.dart';
import 'package:bleed_client/enums.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/inventory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'tips.dart';

// properties
bool get textFieldFocused => hud.focusNodes.textFieldMessage.hasPrimaryFocus;
String get currentTip => tips[tipIndex];

final HudState hud = HudState();

double squareSize = 80;
double halfSquareSize = squareSize * 0.5;
double padding = 3;
double w = squareSize * inventory.columns + padding;
double h = squareSize * inventory.rows + padding;

int tipIndex = 0;

int getScoreRecord(Score score) {
  return score.record;
}

int get enemiesLeft {
  int count = 0;

  if (state.player.squad == -1) {
    for (Character player in compiledGame.humans) {
      if (player.state != CharacterState.Dead) continue;
      count++;
    }
    return count - 1;
  }

  for (Character player in compiledGame.humans) {
    if (player.state == CharacterState.Dead) continue;
    if (player.squad == state.player.squad) continue;
    count++;
  }
  return count;
}


class HudState {
  final _State state = _State();
  final _FocusNodes focusNodes = _FocusNodes();
  final _StateSetters stateSetters = _StateSetters();
  final _TextEditingControllers textEditingControllers = _TextEditingControllers();
  final _Properties properties = _Properties();
}

class _StateSetters {
  StateSetter bottomLeft;
  StateSetter score;
  StateSetter npcMessage;
  StateSetter playerMessage;
  StateSetter topRight;
}

class _State {
  bool textBoxVisible = false;
  bool observeMode = false;
  bool showScore = true;
  bool showServers = false;
  bool expandScore = false;
  bool menuVisible = false;
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


Ring healthRing = Ring(16);

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

