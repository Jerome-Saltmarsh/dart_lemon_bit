
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaFarmA extends DarkAgeArea {
  AreaFarmA() : super(darkAgeScenes.farmA, mapTile: MapTiles.FarmA);

  @override
  int get areaType => AreaType.Farm;
}