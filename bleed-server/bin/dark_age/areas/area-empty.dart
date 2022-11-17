
import '../../common/src/area_type.dart';
import '../../common/src/map_tiles.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaEmpty extends DarkAgeArea {
  AreaEmpty() : super(darkAgeScenes.farmA, mapTile: MapTiles.FarmA);

  @override
  void updateInProgress(){}

  @override
  int get areaType => AreaType.None;
}