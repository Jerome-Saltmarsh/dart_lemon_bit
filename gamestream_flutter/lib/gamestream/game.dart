import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/common/src/game_error.dart';

abstract class Game {
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
