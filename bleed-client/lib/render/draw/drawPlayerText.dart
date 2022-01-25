import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/state/game.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';

final _playerTextStyle = TextStyle(color: Colors.white);

void drawPlayerText() {
  for (int i = 0; i < game.totalHumans; i++) {
    Character human = game.humans[i];
    if (human.text.isEmpty) continue;
    double width = charWidth * human.text.length;
    double left = human.x - width;
    double y = human.y - 50;
    engine.draw.text(human.text, left, y, style: _playerTextStyle);
  }
}
