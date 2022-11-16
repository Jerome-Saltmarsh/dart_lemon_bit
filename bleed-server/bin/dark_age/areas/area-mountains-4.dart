
import '../../common/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountains4 extends DarkAgeArea {
  AreaMountains4() : super(darkAgeScenes.mountains_4, mapTile: MapTiles.Mountains_4);

  @override
  int get areaType => AreaType.Mountains;
}