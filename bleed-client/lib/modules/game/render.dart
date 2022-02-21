
import 'dart:math';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/OrbType.dart';
import 'package:bleed_client/common/configuration.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/modules/game/queries.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/opposite.dart';

import 'state.dart';
import 'style.dart';


class GameRender {

  final GameQueries queries;
  final GameState state;
  final GameStyle style;

  GameRender(this.state, this.style, this.queries);

  void render(Canvas canvas, Size size) {

    applyFrameSmoothing();

    if (state.player.uuid.value.isEmpty) {
      return;
    }
    if (state.status.value == GameStatus.Awaiting_Players){
      return;
    }

    isometric.actions.applyDynamicEmissions();
    isometric.actions.applyDynamicShadeToTileSrc();
    isometric.render.tiles();
    drawProjectiles(game.projectiles);
    drawBulletHoles(game.bulletHoles);

    drawAbility();
    attackTargetCircle();

    if (state.compilePaths.value) {
      drawPaths();
      drawDebugNpcs(game.npcDebug);
    }

    engine.setPaintColorWhite();
    isometric.render.sprites();
    drawEffects();
    drawItems();

    // _renderCharacterHealthBars();
    // if (game.type.value == GameType.BATTLE_ROYAL){
    //   drawRoyalPerimeter();
    // }
    // engine.setPaintColorWhite();
    // _drawFloatingTexts();
    // _drawPlayerNames();
    // drawPlayerText();
    engine.setPaintColorWhite();
    // collectedOrbImage();
  }

  void collectedOrbImage() {
     final totalFrames = 60;
    final totalFramesHalf = ((totalFrames) * 0.5).toInt();
    final framesSinceOrbAcquired = state.framesSinceOrbAcquired;

    if (framesSinceOrbAcquired < totalFrames) {
      double y = 0;
      final max = 30.0;
      if (framesSinceOrbAcquired < totalFramesHalf){
        y = framesSinceOrbAcquired / totalFramesHalf * max;
      } else {
        y = (totalFrames - framesSinceOrbAcquired) / totalFramesHalf * max;
      }

      engine.render(
        dstX: state.player.x,
        dstY: state.player.y - y - 30,
        srcX: state.lastOrbAcquired == OrbType.Emerald ? atlas.orbEmerald.x
              :
              state.lastOrbAcquired == OrbType.Ruby ? atlas.orbRuby.x
              :
              atlas.orbTopaz.x,
        srcY: atlas.orbTopaz.y,
        srcSize: 24,
        scale: 0.7
      );
    }
  }

  void applyFrameSmoothing() {
    if (!state.frameSmoothing.value) return;
    if (state.smoothed >= 0) return;
      state.smoothed--;
      for(final character in game.humans) {
        if (character.state.running) {
          final angle = character.angle;
          final speed = 0.5;
          character.x += adjacent(angle, speed);
          character.y += opposite(angle, speed);
        }
      }
  }

  void weaponRangeCircle() {
    engine.draw.drawCircleOutline(
        radius: state.player.slots.weapon.value.range,
        x: state.player.x,
        y: state.player.y,
        color: colours.white80,
        sides: 10
    );
  }

  void attackTargetCircle() {
    final Vector2 attackTarget = state.player.attackTarget;
    if (attackTarget.x != 0 && attackTarget.y != 0) {
      engine.draw.circle(attackTarget.x, attackTarget.y, 20, Colors.white24);
    }
  }

  void _renderCharacterHealthBars() {
    for (int i = 0; i < game.totalHumans; i++) {
      isometric.render.drawCharacterHealthBar(game.humans[i]);
    }
    for (int i = 0; i < game.totalZombies.value; i++) {
      isometric.render.drawCharacterHealthBar(game.zombies[i]);
    }
  }

  void drawAbility() {

    final player = state.player;
    if (player.ability.value == AbilityType.None) return;

    // drawMouseAim2();

    engine.draw.drawCircleOutline(
        sides: 24,
        radius: player.abilityRange,
        x: player.x,
        y: player.y,
        color: Colors.white);

    if (player.abilityRadius != 0){
      engine.draw.drawCircleOutline(
          sides: 12,
          radius: player.abilityRadius,
          x: mouseWorldX,
          y: mouseWorldY,
          color: Colors.white);
    }
  }

  void drawDebugNpcs(List<NpcDebug> values){
    engine.setPaintColor(Colors.yellow);

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
      final player = game.humans[i];
      if (player.x == state.player.x) continue;
      if (diff(mouseWorldX, player.x) > style.nameRadius) continue;
      if (diff(mouseWorldY, player.y) > style.nameRadius) continue;

      engine.draw.text(player.name, player.x - isometric.constants.charWidth * player.name.length, player.y, style: style.playerNameTextStyle);
    }
  }

  void drawPaths() {
    engine.setPaintColor(colours.blue);
    engine.paint.strokeWidth = 4.0;
    for (final path in isometric.state.paths) {
      for (int i = 0; i < path.length - 1; i++) {
        drawLine(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
      }
    }
  }

  void drawBulletHoles(List<Vector2> bulletHoles) {
    for (final bulletHole in bulletHoles) {
      if (bulletHole.x == 0) return;
      if (!onScreen(bulletHole.x, bulletHole.y)) continue;
      if (isometric.state.inDarkness(bulletHole.x, bulletHole.y)) continue;
      engine.draw.circle(bulletHole.x, bulletHole.y, 2, Colors.black);
    }
  }

  void drawProjectiles(List<Projectile> projectiles) {
    for (int i = 0; i < game.totalProjectiles; i++) {
      projectile(game.projectiles[i]);
    }
  }

  void mapDstProjectile(Projectile projectile){
    engine.mapDst(x: projectile.x, y: projectile.y, scale: 0.25, anchorX: 16, anchorY: 16);
  }

  void projectile(Projectile value) {
    switch (value.type) {
      case ProjectileType.Fireball:
        drawFireball(value.x, value.y, value.angle);
        break;
      case ProjectileType.Arrow:
        arrow(value.x, value.y, value.angle);
        break;
      case ProjectileType.Blue_Orb:
        engine.draw.circle(value.x, value.y, 5, colours.blue);
        break;
    }
  }

  void drawFireball(double x, double y, double angle) {
    RSTransform rsTransform = RSTransform.fromComponents(
        rotation: angle,
        scale: 1,
        anchorX: 16,
        anchorY: 16,
        translateX: x,
        translateY: y);
    int frame = core.state.timeline.frame % 4;
    Rect rect = Rect.fromLTWH(atlas.projectiles.fireball.x, atlas.projectiles.fireball.y + (frame * atlas.projectiles.fireball.size),
        atlas.projectiles.fireball.size, atlas.projectiles.fireball.size);

    // TODO use atlas instead
    engine.canvas.drawAtlas(isometric.state.image, [rsTransform],
        [rect], null, null, null, engine.paint);
  }

  void arrow(double x, double y, double angle) {
    engine.mapSrc(x: atlas.projectiles.arrow.x, y: atlas.projectiles.arrow.y, width: 13, height: 47);
    engine.mapDst(x: x, y: y - 20, rotation: angle, anchorX: 6.5, anchorY: 30, scale: 0.5);
    engine.renderAtlas();
    engine.mapSrc(x: atlas.projectiles.arrowShadow.x, y: atlas.projectiles.arrowShadow.y, width: 13, height: 47);
    engine.mapDst(x: x, y: y, rotation: angle, anchorX: 6.5, anchorY: 30, scale: 0.5);
    engine.renderAtlas();
  }

  void drawItems() {
    final isoState = isometric.state;
    for (int i = 0; i < game.itemsTotal; i++){
      isometric.render.renderItem(isoState.items[i]);
    }
  }

  void drawEffects() {
    for (final effect in game.effects) {
      if (!effect.enabled) continue;
      if (effect.duration++ >= effect.maxDuration) {
        effect.enabled = false;
        break;
      }

      if (effect.type == EffectType.FreezeCircle) {
        final percentage = effect.duration / effect.maxDuration;
        engine.draw.drawCircleOutline(
            sides: 16,
            radius: SpellRadius.Freeze_Ring * percentage,
            x: effect.x,
            y: effect.y,
            width: 10,
            color: colours.blue.withOpacity(1.0 - percentage)
        );
      }
    }
  }

  void drawRoyalPerimeter() {
    engine.draw.drawCircleOutline(sides: 50, radius: game.royal.radius, x: game.royal.mapCenter.x, y: game.royal.mapCenter.y, color: Colors.red);
  }

  void drawMouseAim2() {
    engine.setPaintColorWhite();
    double angle = queries.getAngleBetweenMouseAndPlayer();
    double mouseDistance = queries.getDistanceBetweenMouseAndPlayer();
    double d = min(mouseDistance, modules.game.state.player.attackRange);
    double vX = adjacent(angle, d);
    double vY = opposite(angle, d);
    drawLine(modules.game.state.player.x, modules.game.state.player.y, modules.game.state.player.x + vX, modules.game.state.player.y + vY);
  }

  void drawDebugEnvironmentObjects() {
    engine.paint.color = Colors.red;
    for (EnvironmentObject env in modules.isometric.state.environmentObjects) {
      drawLine(env.left, env.top, env.right, env.top); // top left to top right
      drawLine(
          env.right, env.top, env.right, env.bottom); // top left to bottom right
      drawLine(env.right, env.bottom, env.left, env.bottom);
      drawLine(env.left, env.top, env.left, env.bottom);
    }
    for (EnvironmentObject env in modules.isometric.state.environmentObjects) {
      engine.draw.circle(env.x, env.y, env.radius, Colors.blue);
    }
  }


  void _drawMouseAim() {
    // if (modules.game.state.player.dead) return;
    //
    // engine.state.paint.strokeWidth = 3;
    // double angle =
    // angleBetween(mouseWorldX, mouseWorldY, modules.game.state.player.x, modules.game.state.player.y);
    //
    // double mouseDistance =
    // distanceBetween(mouseWorldX, mouseWorldY, modules.game.state.player.x, modules.game.state.player.y);
    //
    // double scope = queries.mapWeaponAimLength(modules.game.state.soldier.weaponType.value);
    // double d = min(mouseDistance, scope);
    //
    // double vX = adjacent(angle, d);
    // double vY = opposite(angle, d);
    // Offset mouseOffset = Offset(mouseWorldX, mouseWorldY);
    // Offset aimOffset = Offset(mouseWorldX + vX, mouseWorldY + vY);
    // _drawLine(mouseOffset, aimOffset, Colors.transparent);
    // engine.actions.setPaintColorWhite();
  }

  void drawPlayerText() {
    for (int i = 0; i < game.totalHumans; i++) {
      Character human = game.humans[i];
      if (human.text.isEmpty) continue;
      double width = isometric.constants.charWidth * human.text.length;
      double left = human.x - width;
      double y = human.y - 50;
      engine.draw.text(human.text, left, y, style: state.playerTextStyle);
    }
  }

}