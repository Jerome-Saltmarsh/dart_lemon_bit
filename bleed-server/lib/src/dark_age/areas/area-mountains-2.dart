
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountains2 extends DarkAgeArea {
  AreaMountains2() : super(scene: darkAgeScenes.mountains_2, mapTile: MapTiles.Mountains_2);

  @override
  int get areaType => AreaType.Mountains;
}