
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaForestB extends DarkAgeArea {
  AreaForestB() : super(darkAgeScenes.forest_2, mapTile: MapTiles.ForestB);

  @override
  int get areaType => AreaType.Forest;
}