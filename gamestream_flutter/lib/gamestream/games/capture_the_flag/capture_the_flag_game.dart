


import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';

class CaptureTheFlagGame extends GameIsometric {

  @override
  Widget buildUI(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: 16,
            right: 16,
            child: GameIsometricUI.buildMapCircle(size: 200),
        ),
      ],
    );
  }
}