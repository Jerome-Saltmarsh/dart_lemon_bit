
import 'package:bleed_server/common/src/area_type.dart';

import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeFortressDungeon extends DarkAgeArea {
  GameDarkAgeFortressDungeon() : super(darkAgeScenes.darkFortressDungeon, mapTile: -1) {

  }

  @override
  void customUpdate() {
  }

  @override
  int get areaType => AreaType.None;
}