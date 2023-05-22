

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

import 'game.dart';


class GameFight2D extends Game {
  static var totalPlayers = 0;
  static final playerPositionX = Float32List(1000);
  static final playerPositionY = Float32List(1000);


  @override
  void drawCanvas(Canvas canvas, Size size) {
      Engine.cameraCenter(0, 0);
      Engine.zoom = 1.0;
      Engine.targetZoom = 1.0;

      for (var i = 0; i < totalPlayers; i++){
        canvas.drawCircle(Offset(playerPositionX[i].toDouble(), playerPositionY[i].toDouble()), 100, Engine.paint);
      }
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    // TODO: implement renderForeground
  }

  @override
  void update() {
    // TODO: implement update
  }

  @override
  void onActivated() {
    // TODO: implement onActivated
  }

  @override
  Widget buildUI(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: 16,
            right: 16,
            child: Text("FIGHT2D")
        )
      ],
    );
  }
}

