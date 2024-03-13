import 'package:amulet_common/src.dart';
import 'package:amulet_flutter/isometric/components/isometric_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


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

  void onKeyPressed(PhysicalKeyboardKey key) {

  }

  void onMouseEnter(){

  }

  void onMouseExit(){

  }

  void onGameError(GameError error){}
}
