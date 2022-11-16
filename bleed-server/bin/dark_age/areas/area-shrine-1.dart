
import '../../common/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaShrine1 extends DarkAgeArea {
  AreaShrine1() : super(darkAgeScenes.shrine_1, mapTile: MapTiles.Shrine_1);

  @override
  int get areaType => AreaType.Plains;
}