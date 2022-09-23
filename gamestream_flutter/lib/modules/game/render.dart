import 'package:bleed_common/attack_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/isometric/ai.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/render/render_character_health_bar.dart';
import 'package:gamestream_flutter/isometric/render/render_circle.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/render/render_wireframe.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/utils/mouse_raycast.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';
import 'state.dart';
import 'style.dart';

final renderFrame = Watch(0);

class GameRender {
  final GameState state;
  final GameStyle style;

  bool get debug => state.debug.value;

  GameRender(this.state, this.style);

  void renderForeground(Canvas canvas, Size size) {
    engine.setPaintColorWhite();
    _renderPlayerNames();
    drawPlayerText();
  }

  void renderGame(Canvas canvas, Size size) {
    renderFrame.value++;
    interpolatePlayer();
    updateCameraMode();
    attackTargetCircle();
    renderSprites();
    renderEditMode();
    renderMouseTargetName();
    renderWeaponRoundInformation();
    serverResponseReader.rendersSinceUpdate.value++;
  }

  /// Render the player in the same relative position to the camera
  void interpolatePlayer(){

    if (!player.interpolating.value) return;

    if (serverResponseReader.rendersSinceUpdate.value == 0) {
      return;
    }
    if (serverResponseReader.rendersSinceUpdate.value != 1) return;

    final playerCharacter = getPlayerCharacter();
    if (playerCharacter == null) return;
    final velocityX = player.x - player.previousPosition.x;
    final velocityY = player.y - player.previousPosition.y;
    final velocityZ = player.z - player.previousPosition.z;
    playerCharacter.x += velocityX;
    playerCharacter.y += velocityY;
    playerCharacter.z -= velocityZ;
  }

  void renderWeaponRoundInformation() {
    if (!AttackType.requiresRounds(player.weaponType.value))
      return;

    renderText(
      text: player.weaponRounds.value.toString(),
      x: player.renderX,
      y: player.renderY - 55,
    );

    renderCharacterBarWeaponRounds(
      x: player.renderX,
      y: player.renderY - 7,
      percentage: player.weaponRoundPercentage,
    );
  }

  void renderTutorialKeys() {
     const distance = 50;
    render(
       srcX: 1840,
        srcY: 33,
        dstX: player.renderX,
        dstY: player.renderY + distance,
        srcWidth: 32,
        srcHeight: 32,
    );

    // A
    render(
      srcX: 1840,
      srcY: 99,
      dstX: player.renderX - distance,
      dstY: player.renderY,
      srcWidth: 32,
      srcHeight: 32,
    );

    // D
    render(
      srcX: 1840,
      srcY: 0,
      dstX: player.renderX + distance,
      dstY: player.renderY,
      srcWidth: 32,
      srcHeight: 32,
    );
    render(
      srcX: 1840,
      srcY: 66,
      dstX: player.renderX,
      dstY: player.renderY - distance,
      srcWidth: 32,
      srcHeight: 32,
    );
  }

  void renderEditMode() {
    if (!playModeEdit) return;
    if (edit.gameObjectSelected.value){
      engine.draw.drawCircleOutline(
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
       engine.draw.drawCircleOutline(
           radius: nodeData.spawnRadius.toDouble(),
           x: edit.renderX,
           y: edit.renderY,
           color: Colors.white,
           sides: 8,
       );
    }
  }

  void renderMouseTargetName() {
    if (!player.mouseTargetAllie.value) return;
    final mouseTargetName = player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    renderText(
        text: mouseTargetName,
        x: player.attackTarget.renderX,
        y: player.attackTarget.renderY - 55);
  }

  void renderMouseWireFrame() {
    mouseRaycast(renderWireFrameBlue);
  }

  void renderEditWireFrames() {
    for (var z = 0; z < edit.z.value; z++) {
      renderWireFrameBlue(z, edit.row.value, edit.column.value);
    }
    renderWireFrameRed(edit.row.value, edit.column.value, edit.z.value);
  }

  void renderTeamColours() {
    for (var i = 0; i < totalZombies; i++) {
      renderTeamColour(zombies[i]);
    }
  }

  void renderTeamColour(Character character) {
    engine.draw.circle(character.x, character.y, 10,
        character.allie ? Colors.green : Colors.red);
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

    engine.setPaintColor(colours.yellow);
    final totalLines = targetsTotal * 4;
    for (var i = 0; i < totalLines; i += 4) {
      drawLine(targets[i], targets[i + 1], targets[i + 2], targets[i + 3]);
    }
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
