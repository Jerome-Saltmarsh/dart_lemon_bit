
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/isometric/ai.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/npc_debug.dart';
import 'package:gamestream_flutter/isometric/collectables.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/render/render_wireframe.dart';
import 'package:gamestream_flutter/isometric/utils/mouse_raycast.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:gamestream_flutter/modules/game/queries.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/library.dart';

import 'state.dart';
import 'style.dart';

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
      // renderFloatingTexts();
  }

  void renderGame(Canvas canvas, Size size) {
    drawAbility();
    attackTargetCircle();
    renderSprites();

    if (playModeEdit){
      if (edit.gameObjectSelected.value){
        renderCircleV3(edit.gameObject);
      } else {
        renderEditWireFrames();
        renderMouseWireFrame();
      }
    }

    final mouseTargetName = player.mouseTargetName.value;

    if (mouseTargetName != null && mouseTargetName != "Zombie"){
       renderText(text: mouseTargetName, x: player.attackTarget.renderX, y: player.attackTarget.renderY - 55);
    }
    // renderPixelRed(player.target.renderX, player.target.renderY);


  }

  void renderMouseWireFrame(){
    mouseRaycast(renderWireFrameBlue);
  }

  void renderEditWireFrames() {
     for (var z = 0; z < edit.z.value; z++){
       renderWireFrameBlue(z, edit.row.value, edit.column.value);
    }
    renderWireFrameRed(
        edit.row.value,
        edit.column.value,
        edit.z.value
    );
  }

  void renderTeamColours() {
    for (var i = 0; i < totalZombies; i++) {
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
    for (var i = 0; i < totalCollectables; i++) {
      final collectable = collectables[i];
      switch (collectable.type) {
        case CollectableType.Wood:
          // isometric.render.renderIconWood(collectable);
          continue;
        case CollectableType.Stone:
          // isometric.render.renderIconStone(collectable);
          continue;
        case CollectableType.Experience:
          // isometric.render.renderIconExperience(collectable);
          continue;
        case CollectableType.Gold:
          // isometric.render.renderIconGold(collectable);
          continue;
      }
    }
  }

  void attackTargetCircle() {
    // final attackTarget = state.player.attackTarget;
    // final x = attackTarget.x;
    // final y = attackTarget.y;
    // if (x == 0 && y == 0) return;
    // final shade = isometric.getShadeAtPosition(x, y);
    // if (shade >= Shade.Very_Dark) return;
    // drawCircle36(x, y);
  }

  void drawCircle36V2(Position vector2){
    drawCircle36(vector2.x, vector2.y);
  }

  void drawCircle36(double x, double y){
    // engine.render(dstX: x, dstY: y, srcX: 2420, srcY: 57, srcSize: 37);
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
    final total = totalPlayers;
    for (var i = 0; i < total; i++) {
      final player = players[i];
      if (player.dead) continue;
      const minDistance = 15;
      if (diffOver(mouseWorldX, player.x, minDistance)) continue;
      if (diffOver(mouseWorldY, player.y - player.z, minDistance)) continue;
      renderText(text: player.name, x: player.x, y: player.y + 5 - player.z);
    }
  }

  void drawPaths() {
    if (!state.debug.value) return;
    engine.setPaintColor(colours.blue);
    paint.strokeWidth = 4.0;

    var index = 0;
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
    final totalLines = targetsTotal * 4;
    for (var i = 0; i < totalLines; i += 4){
      drawLine(targets[i], targets[i + 1], targets[i + 2], targets[i + 3]);
    }
  }

  void drawBulletHoles(List<Vector2> bulletHoles) {
    for (final bulletHole in bulletHoles) {
      if (bulletHole.x == 0) return;
      if (!engine.screen.contains(bulletHole.x, bulletHole.y)) continue;
      // render(
      //     dstX: bulletHole.x,
      //     dstY: bulletHole.y,
      //     srcX: 1,
      //     srcY: 1,
      //     srcSize: 4,
      // );
    }
  }

  void drawMouseAim2() {
    engine.setPaintColorWhite();
    double angle = queries.getAngleBetweenMouseAndPlayer();
    double mouseDistance = queries.getDistanceBetweenMouseAndPlayer();
    double d = min(mouseDistance, player.attackRange);
    double vX = getAdjacent(angle, d);
    double vY = getOpposite(angle, d);
    drawLine(player.x, player.y, player.x + vX, player.y + vY);
  }

  void drawPlayerText() {
    const charWidth = 4.5;
    for (var i = 0; i < totalPlayers; i++) {
      final human = players[i];
      if (human.text.isEmpty) continue;
      final width = charWidth * human.text.length;
      final left = human.renderX - width;
      final y = human.renderY - 70;
      engine.renderText(human.text, left, y, style: state.playerTextStyle);
    }
  }

}