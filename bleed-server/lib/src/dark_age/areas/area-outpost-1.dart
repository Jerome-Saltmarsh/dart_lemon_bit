
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaOutpost1 extends DarkAgeArea {
  AreaOutpost1() : super(scene: darkAgeScenes.outpost_1, mapTile: MapTiles.Outpost_1);

  @override
  int get areaType => AreaType.None;
}