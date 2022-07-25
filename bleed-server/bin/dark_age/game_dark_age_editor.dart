
import '../classes/player.dart';
import '../classes/scene.dart';
import '../scene/generate_empty_scene.dart';
import 'dark_age_environment.dart';
import 'game_dark_age.dart';

class GameDarkAgeEditor extends GameDarkAge {
  GameDarkAgeEditor({Scene? scene}) : super(scene ?? generateEmptyScene(), DarkAgeEnvironment(DarkAgeTime()));

  @override
  void update(){
    environment.update();
  }

  @override
  void onPlayerDisconnected(Player player) {
      removeFromEngine();
  }
}