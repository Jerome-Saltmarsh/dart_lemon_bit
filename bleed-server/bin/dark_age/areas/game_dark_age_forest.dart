
import '../../common/map_tiles.dart';
import '../../common/src/area_type.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeForest extends DarkAgeArea {
  GameDarkAgeForest() : super(darkAgeScenes.forest, mapTile: MapTiles.Forest);

  @override
  int get areaType => AreaType.Forest;
}