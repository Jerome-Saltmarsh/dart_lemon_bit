import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/ai.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/render/render_character_health_bar.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/render/render_wireframe.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/utils/mouse_raycast.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import '../../isometric/game.dart';
import 'style.dart';

final renderFrame = Watch(0);
final rendersSinceUpdate = Watch(0, onChanged: onChangedRendersSinceUpdate);

class GameRender {
  final GameStyle style;

  bool get debug => game.debug.value;

  GameRender(this.style);

  void renderForeground(Canvas canvas, Size size) {
    Engine.setPaintColorWhite();
    _renderPlayerNames();
    drawPlayerText();
  }


  void renderGame(Canvas canvas, Size size) {
    /// particles are only on the ui and thus can update every frame
    /// this makes them much smoother as they don't freeze
    updateParticles();
    renderFrame.value++;
    interpolatePlayer();
    updateCameraMode();
    attackTargetCircle();
    renderSprites();
    renderEditMode();
    renderMouseTargetName();
    renderWeaponRoundInformation();
    rendersSinceUpdate.value++;
  }

  /// Render the player in the same relative position to the camera
  void interpolatePlayer(){

    if (!GameState.player.interpolating.value) return;

    if (rendersSinceUpdate.value == 0) {
      return;
    }
    if (rendersSinceUpdate.value != 1) return;

    final playerCharacter = GameState.getPlayerCharacter();
    if (playerCharacter == null) return;
    final velocityX = GameState.player.x - GameState.player.previousPosition.x;
    final velocityY = GameState.player.y - GameState.player.previousPosition.y;
    final velocityZ = GameState.player.z - GameState.player.previousPosition.z;
    playerCharacter.x += velocityX;
    playerCharacter.y += velocityY;
    playerCharacter.z -= velocityZ;
  }

  void renderWeaponRoundInformation() {
    if (GameState.player.weapon.capacity.value <= 0)
      return;

    // renderText(
    //   text: player.weapon.rounds.value.toString(),
    //   x: player.renderX,
    //   y: player.renderY - 55,
    // );

    renderCharacterBarWeaponRounds(
      x: GameState.player.renderX,
      y: GameState.player.renderY - 7,
      percentage: GameState.player.weaponRoundPercentage,
    );
  }

  void renderEditMode() {
    if (playMode) return;
    if (edit.gameObjectSelected.value){
      Engine.renderCircleOutline(
        sides: 24,
        radius: edit.gameObjectSelectedRadius.value,
        x: edit.gameObject.renderX,
        y: edit.gameObject.renderY,
        color: Colors.white,
      );
      return renderCircleV3(edit.gameObject);
    }

    renderEditWireFrames();
    renderMouseWireFrame();

    final nodeData = edit.selectedNodeData.value;
    if (nodeData != null){
      Engine.renderCircleOutline(
           radius: nodeData.spawnRadius.toDouble(),
           x: edit.renderX,
           y: edit.renderY,
           color: Colors.white,
           sides: 8,
       );
    }
  }

  void renderMouseTargetName() {
    if (!GameState.player.mouseTargetAllie.value) return;
    final mouseTargetName = GameState.player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    renderText(
        text: mouseTargetName,
        x: GameState.player.attackTarget.renderX,
        y: GameState.player.attackTarget.renderY - 55);
  }

  void renderMouseWireFrame() {
    mouseRaycast(renderWireFrameBlue);
  }

  void renderEditWireFrames() {
    for (var z = 0; z < edit.z; z++) {
      renderWireFrameBlue(z, edit.row, edit.column);
    }
    renderWireFrameRed(edit.row, edit.column, edit.z);
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

  void _renderPlayerNames() {
    final total = GameState.totalPlayers;
    for (var i = 0; i < total; i++) {
      final player = GameState.players[i];
      if (player.dead) continue;
      const minDistance = 15;
      if (diffOver(mouseWorldX, player.x, minDistance)) continue;
      if (diffOver(mouseWorldY, player.y - player.z, minDistance)) continue;
      renderText(text: player.name, x: player.x, y: player.y + 5 - player.z);
    }
  }

  void drawPaths() {
    if (!game.debug.value) return;
    Engine.setPaintColor(colours.blue);
    Engine.paint.strokeWidth = 4.0;

    var index = 0;
    while (true) {
      final length = paths[index];
      if (length == 250) break;
      index++;
      var aX = paths[index];
      index++;
      var aY = paths[index];
      index++;
      for (var i = 1; i < length; i++) {
        final bX = paths[index];
        final bY = paths[index + 1];
        index += 2;
        drawLine(aX, aY, bX, bY);
        aX = bX;
        aY = bY;
      }
    }

    Engine.setPaintColor(colours.yellow);
    final totalLines = targetsTotal * 4;
    for (var i = 0; i < totalLines; i += 4) {
      drawLine(targets[i], targets[i + 1], targets[i + 2], targets[i + 3]);
    }
  }

  void drawPlayerText() {
    const charWidth = 4.5;
    for (var i = 0; i < GameState.totalPlayers; i++) {
      final human = GameState.players[i];
      if (human.text.isEmpty) continue;
      final width = charWidth * human.text.length;
      final left = human.renderX - width;
      final y = human.renderY - 70;
      Engine.renderText(human.text, left, y, style: game.playerTextStyle);
    }
  }
}
