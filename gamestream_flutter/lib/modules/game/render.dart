
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Explosion.dart';
import 'package:gamestream_flutter/classes/NpcDebug.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/modules/game/queries.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import 'state.dart';
import 'style.dart';

final _screen = engine.screen;
final _render = isometric.render;
final _projectiles = game.projectiles;
final _bulletHoles = game.bulletHoles;
final _floatingTexts = isometric.floatingTexts;

class GameRender {

  final GameQueries queries;
  final GameState state;
  final GameStyle style;

  GameRender(this.state, this.style, this.queries);

  void renderForeground(Canvas canvas, Size size) {
      engine.setPaintColorWhite();
      _renderPlayerNames();
      drawPlayerText();
      // drawItemText();

      for (final floatingText in _floatingTexts) {
        if (floatingText.duration <= 0) continue;
        floatingText.duration--;
        renderText(
            text: floatingText.value,
            x: floatingText.x,
            y: floatingText.y
        );
        floatingText.y -= 1;
        floatingText.x += floatingText.xv;
      }
  }

  void render(Canvas canvas, Size size) {
    isometric.applyDynamicEmissions();
    isometric.applyDynamicShadeToTileSrc();
    _render.renderTiles();
    drawProjectiles(_projectiles);
    drawBulletHoles(_bulletHoles);
    drawAbility();
    if (modules.game.structureType.value == null){
      attackTargetCircle();
    }
    drawPaths();
    renderCollectables();
    _render.renderSprites();
    drawEffects();
    drawItems();
  }

  void renderCollectables() {
    final total = game.totalCollectables;
    final collectables = game.collectables;
    for (var i = 0; i < total; i++) {
      final collectable = collectables[i];
      switch (collectable.type) {
        case CollectableType.Wood:
          isometric.render.renderIconWood(collectable);
          continue;
        case CollectableType.Stone:
          isometric.render.renderIconStone(collectable);
          continue;
        case CollectableType.Experience:
          isometric.render.renderIconExperience(collectable);
          continue;
        case CollectableType.Gold:
          isometric.render.renderIconGold(collectable);
          continue;
      }
    }
  }

  void collectedOrbImage() {
     const totalFrames = 60;
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

  // void weaponRangeCircle() {
  //   engine.draw.drawCircleOutline(
  //       radius: SlotType.getRange(state.player.slots.weapon.type.value).toDouble(),
  //       x: state.player.x,
  //       y: state.player.y,
  //       color: colours.white80,
  //       sides: 10
  //   );
  // }

  void attackTargetCircle() {
    final attackTarget = state.player.attackTarget;
    final x = attackTarget.x;
    final y = attackTarget.y;
    if (x == 0 && y == 0) return;
    final shade = isometric.getShadeAtPosition(x, y);
    if (shade >= Shade.Very_Dark) return;
    drawCircle36(x, y);
  }

  void drawCircle36V2(Position vector2){
    drawCircle36(vector2.x, vector2.y);
  }

  void drawCircle36(double x, double y){
    engine.render(dstX: x, dstY: y, srcX: 2420, srcY: 57, srcSize: 37);
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
    for (final npc in values) {
      drawLine(npc.x, npc.y, npc.targetX, npc.targetY);
    }
  }

  void _renderPlayerNames() {
    final total = game.totalPlayers.value;
    for (var i = 0; i < total; i++) {
      final player = game.players[i];
      if (!engine.screen.containsV(player)) continue;
      if (player.dead) continue;
      const minDistance = 15;
      if (diffOver(mouseWorldX, player.x, minDistance)) continue;
      if (diffOver(mouseWorldY, player.y, minDistance)) continue;
      renderText(text: player.name, x: player.x, y: player.y + 5);
    }
  }

  void drawPaths() {
    if (!state.compilePaths.value) return;
    engine.setPaintColor(colours.blue);
    engine.paint.strokeWidth = 4.0;

    var index = 0;
    final paths = modules.isometric.paths;
    while(true){
      final length = paths[index];
      if (length == 250) break;
      index++;
      var aX = paths[index];
      index++;
      var aY = paths[index];
      index++;
      for(var i = 1; i < length; i++){
        final bX = paths[index];
        final bY = paths[index + 1];
        index += 2;
        drawLine(aX, aY, bX, bY);
        aX = bX;
        aY = bY;
      }
    }

    engine.setPaintColor(colours.yellow);
    final targets = modules.isometric.targets;
    final targetsTotal = modules.isometric.targetsTotal * 4;
    for (var i = 0; i < targetsTotal; i += 4){
      drawLine(targets[i], targets[i + 1], targets[i + 2], targets[i + 3]);
    }
  }

  void drawBulletHoles(List<Vector2> bulletHoles) {
    for (final bulletHole in bulletHoles) {
      if (bulletHole.x == 0) return;
      if (!engine.screen.contains(bulletHole.x, bulletHole.y)) continue;
      if (isometric.inDarkness(bulletHole.x, bulletHole.y)) continue;
      engine.render(
          dstX: bulletHole.x,
          dstY: bulletHole.y,
          srcX: 1,
          srcY: 1,
          srcSize: 4,
      );
    }
  }

  void drawProjectiles(List<Projectile> projectiles) {
    final count = game.totalProjectiles;
    for (var i = 0; i < count; i++) {
      projectile(game.projectiles[i]);
    }
  }

  void mapDstProjectile(Projectile projectile){
    engine.mapDst(x: projectile.x, y: projectile.y, scale: 0.25, anchorX: 16, anchorY: 16);
  }

  void projectile(Projectile value) {
    switch (value.type) {
      case TechType.Bow:
        arrow(value.x, value.y, value.angle);
        break;
      default:
        return;
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
    Rect rect = Rect.fromLTWH(atlas.projectiles.fireball.x, atlas.projectiles.fireball.y + (engine.animationFrame * atlas.projectiles.fireball.size),
        atlas.projectiles.fireball.size, atlas.projectiles.fireball.size);

    // TODO use atlas instead
    engine.canvas.drawAtlas(isometric.image, [rsTransform],
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
    final items = isometric.items;
    for (var i = 0; i < game.itemsTotal; i++){
      isometric.render.renderItem(items[i]);
    }
  }

  void drawItemText() {
    final items = isometric.items;
    final total = game.itemsTotal;
    for (var i = 0; i < total; i++){
      final item = items[i];
      const mouseDist = 100;
      if ((mouseWorldX - item.x).abs() < mouseDist){
        if((mouseWorldY - item.y).abs() < mouseDist){
          renderText(
              text: ItemType.names[item.type] ?? "?",
              x: item.x,
              y: item.y
          );
        }
      }
    }
  }

  void renderText({required String text, required double x, required double y}){
    if (!_screen.contains(x, y)) return;
    const charWidth = 4.5;
    engine.writeText(text, x - charWidth * text.length, y);
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
    double vX = getAdjacent(angle, d);
    double vY = getOpposite(angle, d);
    drawLine(modules.game.state.player.x, modules.game.state.player.y, modules.game.state.player.x + vX, modules.game.state.player.y + vY);
  }

  void drawDebugEnvironmentObjects() {
    engine.paint.color = Colors.red;
    for (EnvironmentObject env in modules.isometric.environmentObjects) {
      drawLine(env.left, env.top, env.right, env.top); // top left to top right
      drawLine(
          env.right, env.top, env.right, env.bottom); // top left to bottom right
      drawLine(env.right, env.bottom, env.left, env.bottom);
      drawLine(env.left, env.top, env.left, env.bottom);
    }
    for (EnvironmentObject env in modules.isometric.environmentObjects) {
      engine.draw.circle(env.x, env.y, env.radius, Colors.blue);
    }
  }

  void drawPlayerText() {
    final players = game.players;
    const charWidth = 4.5;
    final totalPlayers = game.totalPlayers.value;
    for (var i = 0; i < totalPlayers; i++) {
      final human = players[i];
      if (human.text.isEmpty) continue;
      final width = charWidth * human.text.length;
      final left = human.x - width;
      final y = human.y - 70;
      engine.draw.text(human.text, left, y, style: state.playerTextStyle);
    }
  }

}