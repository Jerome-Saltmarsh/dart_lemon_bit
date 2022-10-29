
import 'dart:ui';

import 'package:gamestream_flutter/library.dart';

class GameCanvas {
  static void renderForeground(Canvas canvas, Size size) {
    // if (Engine.joystickEngaged) {
    //   Engine.canvasRenderJoystick(canvas);
    // }
    GameRender.canvasRenderCrossHair(canvas, 5 + GameState.player.weaponCooldown.value * 10);
  }

  static void renderCanvas(Canvas canvas, Size size) {
    /// particles are only on the ui and thus can update every frame
    /// this makes them much smoother as they don't freeze
    GameState.updateParticles();
    GameState.renderFrame.value++;
    GameState.interpolatePlayer();
    GameCamera.update();
    GameRender.renderSprites();
    GameState.renderEditMode();
    GameRender.renderMouseTargetName();
    GameState.rendersSinceUpdate.value++;
    GameRender.renderCircle32(GamePlayer.target.x, GamePlayer.target.y, GamePlayer.target.z);
  }

}