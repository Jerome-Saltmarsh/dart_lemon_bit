
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaForest3 extends DarkAgeArea {
  AreaForest3() : super(scene: darkAgeScenes.forest_3, mapTile: MapTiles.Forest_3);

  @override
  int get areaType => AreaType.Forest;
}