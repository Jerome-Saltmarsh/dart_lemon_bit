import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_ui.dart';
import 'package:gamestream_flutter/isometric/ai.dart';
import 'package:gamestream_flutter/isometric/render/render_character_health_bar.dart';
import 'package:gamestream_flutter/isometric/render/render_floating_texts.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import 'style.dart';



class GameRender {
  final GameStyle style;

  bool get debug => GameUI.debug.value;

  GameRender(this.style);

  void renderForeground(Canvas canvas, Size size) {
    Engine.setPaintColorWhite();
    _renderPlayerNames();
    drawPlayerText();
  }

  // void renderGame(Canvas canvas, Size size) {
  //   /// particles are only on the ui and thus can update every frame
  //   /// this makes them much smoother as they don't freeze
  //   updateParticles();
  //   renderFrame.value++;
  //   interpolatePlayer();
  //   updateCameraMode();
  //   attackTargetCircle();
  //   RenderEngine.renderSprites();
  //   renderEditMode();
  //   renderMouseTargetName();
  //   renderWeaponRoundInformation();
  //   rendersSinceUpdate.value++;
  // }

  /// Render the player in the same relative position to the camera

  void renderWeaponRoundInformation() {
    if (Game.player.weapon.capacity.value <= 0)
      return;

    // renderText(
    //   text: player.weapon.rounds.value.toString(),
    //   x: player.renderX,
    //   y: player.renderY - 55,
    // );

    renderCharacterBarWeaponRounds(
      x: Game.player.renderX,
      y: Game.player.renderY - 7,
      percentage: Game.player.weaponRoundPercentage,
    );
  }

  void _renderPlayerNames() {
    final total = Game.totalPlayers;
    for (var i = 0; i < total; i++) {
      final player = Game.players[i];
      if (player.dead) continue;
      const minDistance = 15;
      if (diffOver(mouseWorldX, player.x, minDistance)) continue;
      if (diffOver(mouseWorldY, player.y - player.z, minDistance)) continue;
      renderText(text: player.name, x: player.x, y: player.y + 5 - player.z);
    }
  }

  void drawPaths() {
    if (!GameUI.debug.value) return;
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
        Engine.drawLine(aX, aY, bX, bY);
        aX = bX;
        aY = bY;
      }
    }

    Engine.setPaintColor(colours.yellow);
    final totalLines = targetsTotal * 4;
    for (var i = 0; i < totalLines; i += 4) {
      Engine.drawLine(targets[i], targets[i + 1], targets[i + 2], targets[i + 3]);
    }
  }

  void drawPlayerText() {
    const charWidth = 4.5;
    for (var i = 0; i < Game.totalPlayers; i++) {
      final human = Game.players[i];
      if (human.text.isEmpty) continue;
      final width = charWidth * human.text.length;
      final left = human.renderX - width;
      final y = human.renderY - 70;
      Engine.renderText(human.text, left, y, style: GameUI.playerTextStyle);
    }
  }
}
