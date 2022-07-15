
import '../../classes/library.dart';
import '../../engine.dart';
import '../game_dark_age.dart';

class DarkAgeArea extends GameDarkAge {
  final int mapX;
  final int mapY;
  DarkAgeArea(Scene scene, {required this.mapX, required this.mapY})
      : super(scene, engine.officialUniverse);
}