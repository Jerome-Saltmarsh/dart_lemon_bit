
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gamestream_flutter/library.dart';

import 'game.dart';



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

