
import '../../classes/library.dart';
import '../../engine.dart';
import '../game_dark_age.dart';


class DarkAgeArea extends GameDarkAge {
  var mapTile = 0;
  DarkAgeArea(Scene scene, {required this.mapTile})
      : super(scene, engine.environmentAboveGround);
}

class DarkAgeAreaUnderground extends GameDarkAge {
  var mapTile = 0;
  DarkAgeAreaUnderground(Scene scene, {required this.mapTile})
      : super(scene, engine.environmentUnderground);
}