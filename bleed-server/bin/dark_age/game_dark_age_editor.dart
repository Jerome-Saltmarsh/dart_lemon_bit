
import '../classes/scene.dart';
import '../scene/generate_empty_scene.dart';
import 'dark_age_universe.dart';
import 'game_dark_age.dart';

class GameDarkAgeEditor extends GameDarkAge {
  GameDarkAgeEditor({Scene? scene}) : super(scene ?? generateEmptyScene(), DarkAgeUniverse(DarkAgeTime()));

  @override
  void update(){
    universe.update();
  }
}