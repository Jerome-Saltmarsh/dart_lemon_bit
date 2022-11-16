
import '../../common/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class Area_Cemetery_1 extends DarkAgeArea {

  @override
  int get areaType => AreaType.Cemetery;

  Area_Cemetery_1() : super(darkAgeScenes.cemetery_1, mapTile: MapTiles.Plains_3);
}