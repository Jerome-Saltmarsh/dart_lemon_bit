
import 'dart:ui';

import 'package:gamestream_flutter/library.dart';

import 'game.dart';


class GameCombat extends Game {
  @override
  void drawCanvas(Canvas canvas, Size size) {
    if (ServerState.gameRunning.value){
      /// particles are only on the ui and thus can update every frame
      /// this makes them much smoother as they don't freeze
      GameState.updateParticles();
    }
    GameState.interpolatePlayer();
    GameCamera.update();
    GameRender.render3D();
    GameState.renderEditMode();
    GameRender.renderMouseTargetName();
    GameCanvas.renderPlayerEnergy();
    ClientState.rendersSinceUpdate.value++;
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    GameCanvas.renderForeground(canvas, size);
  }

}

class GameFight2D extends Game {
  @override
  void drawCanvas(Canvas canvas, Size size) {
      Engine.cameraCenter(0, 0);
      Engine.zoom = 1.0;
      Engine.targetZoom = 1.0;
      canvas.drawCircle(const Offset(0, 0), 100, Engine.paint);
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    // TODO: implement renderForeground
  }
}

