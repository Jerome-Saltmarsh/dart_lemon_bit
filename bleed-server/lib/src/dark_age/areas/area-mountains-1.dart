
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountains1 extends DarkAgeArea {
  AreaMountains1() : super(darkAgeScenes.mountains_1, mapTile: MapTiles.Mountains_1);

  @override
  int get areaType => AreaType.Mountains;
}