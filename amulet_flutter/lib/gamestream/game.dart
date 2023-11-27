import 'package:flutter/cupertino.dart';
import 'package:amulet_flutter/packages/common/src/game_error.dart';

import 'isometric/components/src.dart';

abstract class Game with IsometricComponent
{
  void drawCanvas(Canvas canvas, Size size);
  void renderForeground(Canvas canvas, Size size);
  void update();
  void onActivated();
  Widget buildUI(BuildContext context);

  void onLeftClicked(){

  }

  void onRightClicked(){

  }

  void onKeyPressed(int key) {

  }

  void onMouseEnter(){

  }

  void onMouseExit(){

  }

  void onGameError(GameError error){}
}
