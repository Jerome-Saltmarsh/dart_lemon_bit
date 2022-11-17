
import '../../common/src/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaPlains2 extends DarkAgeArea {
  AreaPlains2() : super(darkAgeScenes.plains_2, mapTile: MapTiles.Plains_2);

  @override
  int get areaType => AreaType.Plains;
}