
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawBullets.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/render/draw/drawPlayerText.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/diff.dart';

import 'state.dart';
import 'style.dart';

class GameRender {

  final GameState state;
  final GameStyle style;

  GameRender(this.state, this.style);

  void render(Canvas canvas, Size size) {

    if (modules.game.state.player.uuid.value.isEmpty) {
      return;
    }
    if (state.status.value == GameStatus.Awaiting_Players){
      return;
    }

    isometric.actions.applyEmissionsToDynamicShadeMap();
    isometric.actions.applyDynamicShadeToTileSrc();
    isometric.render.tiles();
    drawProjectiles(game.projectiles);
    drawBulletHoles(game.bulletHoles);

    if (!modules.game.state.player.isHuman){
      drawAbility();
      final Vector2 attackTarget = state.player.attackTarget;
      if (attackTarget.x != 0 && attackTarget.y != 0){
        engine.draw.circle(attackTarget.x, attackTarget.y, 20, Colors.white24);
      }
    }

    engine.actions.setPaintColorWhite();
    isometric.render.sprites();
    drawEffects();
    drawItems();
    // drawCrates();

    if (game.settings.compilePaths) {
      drawDebugEnvironmentObjects();
      drawPaths();
      drawDebugNpcs(game.npcDebug);
    }

    if (game.type.value == GameType.BATTLE_ROYAL){
      drawRoyalPerimeter();
    }

    _drawFloatingTexts();
    _drawPlayerNames();
    drawPlayerText();
    engine.actions.setPaintColorWhite();
  }

  void drawDebugNpcs(List<NpcDebug> values){
    engine.actions.setPaintColor(Colors.yellow);

    for (NpcDebug npc in values) {
      drawLine(npc.x, npc.y, npc.targetX, npc.targetY);
    }
  }

  void _drawFloatingTexts() {
    for (FloatingText floatingText in isometric.state.floatingText) {
      if (floatingText.duration == 0) continue;
      floatingText.duration--;
      floatingText.y -= 0.5;
      engine.draw.text(floatingText.value, floatingText.x, floatingText.y, style: style.floatingTextStyle);
    }
  }

  void _drawPlayerNames() {
    for (int i = 0; i < game.totalHumans; i++) {
      Character player = game.humans[i];
      if (player.x == state.player.x) continue;
      if (diff(mouseWorldX, player.x) > style.nameRadius) continue;
      if (diff(mouseWorldY, player.y) > style.nameRadius) continue;

      engine.draw.text(player.name, player.x - isometric.constants.charWidth * player.name.length, player.y, style: style.playerNameTextStyle);
    }
  }

  void drawPaths() {
    engine.actions.setPaintColor(colours.blue);
    for (List<Vector2> path in isometric.state.paths) {
      for (int i = 0; i < path.length - 1; i++) {
        drawLine(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
      }
    }
  }

  void drawBulletHoles(List<Vector2> bulletHoles) {
    for (Vector2 bulletHole in bulletHoles) {
      if (bulletHole.x == 0) return;
      if (!onScreen(bulletHole.x, bulletHole.y)) continue;
      if (isometric.properties.inDarkness(bulletHole.x, bulletHole.y)) continue;
      engine.draw.circle(bulletHole.x, bulletHole.y, 2, Colors.black);
    }
  }
}