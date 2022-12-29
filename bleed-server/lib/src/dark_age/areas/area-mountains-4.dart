
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountains4 extends DarkAgeArea {
  AreaMountains4() : super(scene: darkAgeScenes.mountains_4, mapTile: MapTiles.Mountains_4);

  @override
  int get areaType => AreaType.Mountains;
}