
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

import 'modules/modules.dart';
import 'utils.dart';



void drawCharacterCircle(double x, double y, Color color) {
  engine.draw.circle(x, y, 10, color);
}

void drawPaths() {
  engine.actions.setPaintColor(colours.blue);
  for (List<Vector2> path in isometric.state.paths) {
    for (int i = 0; i < path.length - 1; i++) {
      drawLine(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
    }
  }
}

void drawDebugNpcs(List<NpcDebug> values){
  engine.actions.setPaintColor(Colors.yellow);

  for (NpcDebug npc in values) {
    drawLine(npc.x, npc.y, npc.targetX, npc.targetY);
  }
}


void drawBulletHoles(List<Vector2> bulletHoles) {
  for (Vector2 bulletHole in bulletHoles) {
    if (bulletHole.x == 0) return;
    if (!onScreen(bulletHole.x, bulletHole.y)) continue;
    if (inDarkness(bulletHole.x, bulletHole.y)) continue;
    engine.draw.circle(bulletHole.x, bulletHole.y, 2, Colors.black);
  }
}
