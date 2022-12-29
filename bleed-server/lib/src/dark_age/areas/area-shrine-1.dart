
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaShrine1 extends DarkAgeArea {
  AreaShrine1() : super(scene: darkAgeScenes.shrine_1, mapTile: MapTiles.Shrine_1);

  @override
  int get areaType => AreaType.Plains;
}