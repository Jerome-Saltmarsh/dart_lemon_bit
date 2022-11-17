
import '../../common/src/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountains2 extends DarkAgeArea {
  AreaMountains2() : super(darkAgeScenes.mountains_2, mapTile: MapTiles.Mountains_2);

  @override
  int get areaType => AreaType.Mountains;
}