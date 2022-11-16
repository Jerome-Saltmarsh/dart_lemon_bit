


import '../../common/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaLake extends DarkAgeArea {
  AreaLake() : super(darkAgeScenes.lake, mapTile: MapTiles.Lake);

  @override
  int get areaType => AreaType.Lake;
}