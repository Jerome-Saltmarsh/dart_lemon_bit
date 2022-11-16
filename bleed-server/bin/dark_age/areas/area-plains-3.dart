
import '../../common/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaPlains3 extends DarkAgeArea {
  AreaPlains3() : super(darkAgeScenes.plains_3, mapTile: MapTiles.Plains_3);

  @override
  int get areaType => AreaType.Plains;
}