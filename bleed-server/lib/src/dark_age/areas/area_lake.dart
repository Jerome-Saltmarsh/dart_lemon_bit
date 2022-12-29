


import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaLake extends DarkAgeArea {
  AreaLake() : super(scene: darkAgeScenes.lake, mapTile: MapTiles.Lake);

  @override
  int get areaType => AreaType.Lake;
}