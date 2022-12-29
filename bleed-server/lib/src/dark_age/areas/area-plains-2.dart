
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaPlains2 extends DarkAgeArea {
  AreaPlains2() : super(scene: darkAgeScenes.plains_2, mapTile: MapTiles.Plains_2);

  @override
  int get areaType => AreaType.Plains;
}