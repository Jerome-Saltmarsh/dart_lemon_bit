
import 'dart:ui';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/render/draw/drawPlayerText.dart';
import 'package:bleed_client/render/state/floatingText.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/diff.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/draw/drawBullets.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';

class GameRender {

  final _floatingTextStyle = TextStyle(color: Colors.white);
  final double _nameRadius = 100;
  final _playerNameTextStyle = TextStyle(color: Colors.white);

  void render(Canvas canvas, Size size) {

    if (game.player.uuid.value.isEmpty) {
      return;
    }
    if (game.status.value == GameStatus.Awaiting_Players){
      return;
    }

    applyEmissionsToDynamicShadeMap();
    isometric.actions.applyDynamicShadeToTileSrc();
    isometric.render.tiles();
    drawProjectiles(game.projectiles);
    drawBulletHoles(game.bulletHoles);

    if (!game.player.isHuman){
      drawAbility();
      final Vector2 attackTarget = game.player.attackTarget;
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

  void _drawFloatingTexts() {
    for (FloatingText floatingText in floatingText) {
      if (floatingText.duration == 0) continue;
      floatingText.duration--;
      floatingText.y -= 0.5;
      engine.draw.text(floatingText.value, floatingText.x, floatingText.y, style: _floatingTextStyle);
    }
  }

  void _drawPlayerNames() {
    for (int i = 0; i < game.totalHumans; i++) {
      Character player = game.humans[i];
      if (player.x == game.player.x) continue;
      if (diff(mouseWorldX, player.x) > _nameRadius) continue;
      if (diff(mouseWorldY, player.y) > _nameRadius) continue;

      engine.draw.text(player.name, player.x - isometric.constants.charWidth * player.name.length, player.y, style: _playerNameTextStyle);
    }
  }
}