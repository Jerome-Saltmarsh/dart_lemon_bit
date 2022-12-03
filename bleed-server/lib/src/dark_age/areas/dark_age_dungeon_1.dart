
import 'package:bleed_server/gamestream.dart';

import '../../constants/frames_per_second.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class DarkAgeDungeon1 extends DarkAgeArea {
  DarkAgeDungeon1() : super(darkAgeScenes.dungeon_1, mapTile: 0);

  @override
  void customOnCharacterKilled(dynamic target, dynamic src) {
    if (target is AI) {
      target.respawn = framesPerSecond * 10;
    }
  }

  @override
  int get areaType => AreaType.None;
}