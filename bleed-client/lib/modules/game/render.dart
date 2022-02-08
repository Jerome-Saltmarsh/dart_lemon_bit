
import 'dart:math';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/NpcDebug.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/mappers/mapDirectionToAngle.dart';
import 'package:bleed_client/modules/game/queries.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/mapBulletToSrc.dart';
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

    if (modules.game.state.player.uuid.value.isEmpty) {
      return;
    }
    if (state.status.value == GameStatus.Awaiting_Players){
      return;
    }

    isometric.actions.applyEmissionsToDynamicShadeMap();

    for(final item in game.items) {
      isometric.actions.applyShadeDynamicPosition(item.x, item.y, Shade.Bright);
    }

    isometric.actions.applyDynamicShadeToTileSrc();
    isometric.render.tiles();
    drawProjectiles(game.projectiles);
    drawBulletHoles(game.bulletHoles);

    // if (!modules.game.state.player.isHuman){
      drawAbility();
      final Vector2 attackTarget = state.player.attackTarget;
      if (attackTarget.x != 0 && attackTarget.y != 0){
        engine.draw.circle(attackTarget.x, attackTarget.y, 20, Colors.white24);
      }
    // }

    engine.actions.setPaintColorWhite();
    isometric.render.sprites();
    drawEffects();
    drawItems();
    // drawCrates();

    // if (state.compilePaths.value) {
      // drawDebugEnvironmentObjects();
      drawPaths();
      drawDebugNpcs(game.npcDebug);
    // }

    if (game.type.value == GameType.BATTLE_ROYAL){
      drawRoyalPerimeter();
    }

    _drawFloatingTexts();
    _drawPlayerNames();
    drawPlayerText();
    engine.actions.setPaintColorWhite();
  }

  void drawAbility() {
    if (modules.game.state.player.ability.value == AbilityType.None) {
      engine.draw.drawCircleOutline(
          sides: 24,
          radius: modules.game.state.player.attackRange,
          x: modules.game.state.player.x,
          y: modules.game.state.player.y,
          color: Colors.white24);
      return;
    }

    drawMouseAim2();

    engine.draw.drawCircleOutline(
        sides: 24,
        radius: modules.game.state.player.abilityRange,
        x: modules.game.state.player.x,
        y: modules.game.state.player.y,
        color: Colors.white);

    if (modules.game.state.player.abilityRadius != 0){
      engine.draw.drawCircleOutline(
          sides: 12,
          radius: modules.game.state.player.abilityRadius,
          x: mouseWorldX,
          y: mouseWorldY,
          color: Colors.white);
    }
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

  void drawProjectiles(List<Projectile> projectiles) {
    for (int i = 0; i < game.totalProjectiles; i++) {
      drawProjectile(game.projectiles[i]);
    }
  }

  void mapDstProjectile(Projectile projectile){
    engine.state.mapDst(x: projectile.x, y: projectile.y, scale: 0.25, anchorX: 16, anchorY: 16);
  }

  void drawProjectile(Projectile projectile) {
    switch (projectile.type) {
      case ProjectileType.Bullet:
        if (isometric.properties.inDarkness(projectile.x, projectile.y)) return;
        mapDstProjectile(projectile);
        mapProjectileToSrc(projectile);
        engine.actions.renderAtlas();
        break;
      case ProjectileType.Fireball:
        drawFireball(projectile.x, projectile.y, projectile.direction);
        break;
      case ProjectileType.Arrow:
        drawArrow(projectile.x, projectile.y,
            convertDirectionToAngle(projectile.direction));
        break;
      case ProjectileType.Blue_Orb:
        engine.draw.circle(projectile.x, projectile.y, 5, colours.blue);
        break;
    }
  }

  void drawFireball(double x, double y, Direction direction) {
    double angle = mapDirectionToAngle[direction]!;
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
    engine.state.canvas.drawAtlas(isometric.state.image, [rsTransform],
        [rect], null, null, null, engine.state.paint);
  }

  Rect _rectArrow = Rect.fromLTWH(atlas.projectiles.arrow.x, atlas.projectiles.arrow.y, 18, 51);

  void drawArrow(double x, double y, double angle) {
    RSTransform rsTransform = RSTransform.fromComponents(
        rotation: angle,
        scale: 0.5,
        anchorX: 25,
        anchorY: 9,
        translateX: x,
        translateY: y);
    engine.state.canvas.drawAtlas(
        isometric.state.image, [rsTransform], [_rectArrow], null, null, null, engine.state.paint);
  }

  void drawItems() {
    for (int i = 0; i < game.itemsTotal; i++){
      isometric.render.renderItem(game.items[i]);
    }
  }

  void drawEffects() {
    for (Effect effect in game.effects) {
      if (!effect.enabled) continue;
      if (effect.duration++ > effect.maxDuration) {
        effect.enabled = false;
        break;
      }

      if (effect.type == EffectType.FreezeCircle) {
        double p = effect.duration / effect.maxDuration;
        double maxRadius = 75;
        engine.draw.drawCircleOutline(
            sides: 16,
            radius: maxRadius * p,
            x: effect.x,
            y: effect.y,
            color: colours.blue
        );
      }
    }
  }

  void drawRoyalPerimeter() {
    engine.draw.drawCircleOutline(sides: 50, radius: game.royal.radius, x: game.royal.mapCenter.x, y: game.royal.mapCenter.y, color: Colors.red);
  }

  void drawMouseAim2() {
    engine.actions.setPaintColorWhite();
    double angle = queries.getAngleBetweenMouseAndPlayer();
    double mouseDistance = queries.getDistanceBetweenMouseAndPlayer();
    double d = min(mouseDistance, modules.game.state.player.attackRange);
    double vX = adjacent(angle, d);
    double vY = opposite(angle, d);
    drawLine(modules.game.state.player.x, modules.game.state.player.y, modules.game.state.player.x + vX, modules.game.state.player.y + vY);
  }

  void drawDebugEnvironmentObjects() {
    engine.state.paint.color = Colors.red;
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