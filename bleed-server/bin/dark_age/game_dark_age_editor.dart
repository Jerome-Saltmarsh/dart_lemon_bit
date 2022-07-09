
import '../scene/generate_empty_scene.dart';
import 'dark_age_universe.dart';
import 'game_dark_age.dart';

class GameDarkAgeEditor extends GameDarkAge {
  GameDarkAgeEditor() : super(generateEmptyScene(), DarkAgeUniverse());

  @override
  void update(){
    universe.update();
  }
}