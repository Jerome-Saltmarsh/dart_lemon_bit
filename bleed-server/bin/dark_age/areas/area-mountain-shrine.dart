

import '../../common/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountainShrine extends DarkAgeArea {
  AreaMountainShrine() : super(darkAgeScenes.mountainShrine, mapTile: MapTiles.Mountain_Shrine);

  @override
  int get areaType => AreaType.Mountains;
}