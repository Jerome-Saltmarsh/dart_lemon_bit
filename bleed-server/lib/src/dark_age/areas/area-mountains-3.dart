
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountains3 extends DarkAgeArea {
  AreaMountains3() : super(darkAgeScenes.mountains_3, mapTile: MapTiles.Mountains_3);

  @override
  int get areaType => AreaType.Mountains;
}