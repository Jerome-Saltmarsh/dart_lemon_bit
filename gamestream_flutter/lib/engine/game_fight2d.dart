

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

import 'game.dart';


class GameFight2D extends Game {
  static const length = 1000;
  static var characters = 0;
  static final characterState = Uint8List(length);
  static final characterPositionX = Float32List(length);
  static final characterPositionY = Float32List(length);


  @override
  void drawCanvas(Canvas canvas, Size size) {
      Engine.cameraCenter(0, 0);
      Engine.zoom = 1.0;
      Engine.targetZoom = 1.0;

      for (var i = 0; i < characters; i++){
        canvas.drawCircle(
            Offset(
                characterPositionX[i].toDouble(),
                characterPositionY[i].toDouble()
            ), 100, Engine.paint
        );
      }
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    // TODO: implement renderForeground
  }

  @override
  void update() {
    GameNetwork.sendClientRequestUpdate();
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

