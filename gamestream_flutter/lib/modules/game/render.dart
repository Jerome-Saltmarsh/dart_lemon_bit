
import 'dart:math';

import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/classes/Explosion.dart';
import 'package:gamestream_flutter/classes/NpcDebug.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/game/queries.dart';
import 'package:gamestream_flutter/modules/isometric/classes.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/builders/player.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import 'state.dart';
import 'style.dart';

final _screen = engine.screen;
final _render = isometric.render;
final _floatingTexts = isometric.floatingTexts;

class GameRender {

  final GameQueries queries;
  final GameState state;
  final GameStyle style;

  bool get debug => state.debug.value;

  GameRender(this.state, this.style, this.queries);

  void renderForeground(Canvas canvas, Size size) {
      engine.setPaintColorWhite();
      _renderPlayerNames();
      drawPlayerText();

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

  void renderBlockBricks(double x, double y){
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 6530,
        srcWidth: 47,
        srcHeight: 70
    );
  }

  void renderStairsHorizontal(double x, double y){
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 6602,
        srcWidth: 47,
        srcHeight: 70
    );
  }

  void render(Canvas canvas, Size size) {
    isometric.applyDynamicEmissions();
    isometric.applyDynamicShadeToTileSrc();
    _render.renderTiles();
    renderProjectiles();

    drawAbility();
    if (modules.game.structureType.value == null){
      attackTargetCircle();
    }
    drawPaths();
    renderCollectables();
    if (debug) {
      renderTeamColours();
    }

    _render.renderSprites();

    isometric.render.renderWireFrame(game.edit.row, game.edit.column, game.edit.z);
    drawEffects();
    drawItems();
  }

  void renderTeamColours() {
    final total = game.totalZombies.value;
    final zombies = game.zombies;
    for (var i = 0; i < total; i++) {
      renderTeamColour(zombies[i]);
    }
  }

  void renderTeamColour(Character character){
     engine.draw.circle(
         character.x,
         character.y,
         10,
         character.allie ? Colors.green : Colors.red
     );
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
    if (player.deckActiveCardIndex.value == -1) return;

    engine.draw.drawCircleOutline(
        sides: 24,
        radius: player.deckActiveCardRange.value,
        x: player.x,
        y: player.y,
        color: Colors.white,
    );

    engine.draw.drawCircleOutline(
        sides: 24,
        radius: player.deckActiveCardRadius.value,
        x: player.abilityTarget.x,
        y: player.abilityTarget.y,
        color: Colors.white,
    );
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
    if (!state.debug.value) return;
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

  void renderProjectiles() {
    final total = game.totalProjectiles;
    final projectiles = game.projectiles;
    for (var i = 0; i < total; i++) {
      _render.renderProjectile(projectiles[i]);
    }
  }

  void mapDstProjectile(Projectile projectile){
    engine.mapDst(x: projectile.x, y: projectile.y, scale: 0.25, anchorX: 16, anchorY: 16);
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

  // void drawRoyalPerimeter() {
  //   engine.draw.drawCircleOutline(sides: 50, radius: byteStreamParser.royal.radius, x: byteStreamParser.royal.mapCenter.x, y: game.royal.mapCenter.y, color: Colors.red);
  // }

  void drawMouseAim2() {
    engine.setPaintColorWhite();
    double angle = queries.getAngleBetweenMouseAndPlayer();
    double mouseDistance = queries.getDistanceBetweenMouseAndPlayer();
    double d = min(mouseDistance, modules.game.state.player.attackRange);
    double vX = getAdjacent(angle, d);
    double vY = getOpposite(angle, d);
    drawLine(modules.game.state.player.x, modules.game.state.player.y, modules.game.state.player.x + vX, modules.game.state.player.y + vY);
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
      engine.renderText(human.text, left, y, style: state.playerTextStyle);
    }
  }

}