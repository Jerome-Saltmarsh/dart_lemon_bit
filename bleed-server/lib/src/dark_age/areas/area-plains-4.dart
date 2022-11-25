
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaPlains4 extends DarkAgeArea {
  AreaPlains4() : super(darkAgeScenes.plains_4, mapTile: MapTiles.Plains_4);

  @override
  int get areaType => AreaType.Plains;
}