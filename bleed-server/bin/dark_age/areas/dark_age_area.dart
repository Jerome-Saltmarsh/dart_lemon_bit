
import '../../classes/library.dart';
import '../../engine.dart';
import '../game_dark_age.dart';

class DarkAgeArea extends GameDarkAge {
  var mapX = 0;
  var mapY = 0;
  DarkAgeArea(Scene scene, {this.mapX = 0, this.mapY = 0})
      : super(scene, engine.environmentAboveGround);
}


class DarkAgeAreaUnderground extends GameDarkAge {
  var mapX = 0;
  var mapY = 0;
  DarkAgeAreaUnderground(Scene scene, {this.mapX = 0, this.mapY = 0})
      : super(scene, engine.environmentUnderground);
}