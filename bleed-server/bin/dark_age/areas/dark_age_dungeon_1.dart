
import '../../actions/action_spawn_loot.dart';
import '../../classes/library.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class DarkAgeDungeon1 extends DarkAgeAreaUnderground {
  DarkAgeDungeon1() : super(darkAgeScenes.dungeon_1, mapTile: 0);

  @override
  bool get mapVisible => false;

  @override
  void customOnKilled(dynamic target, dynamic src) {
    if (target is AI) {
      actionSpawnLoot(
        game: this,
        x: target.x,
        y: target.y,
        z: target.z,
      );
    }
  }
}