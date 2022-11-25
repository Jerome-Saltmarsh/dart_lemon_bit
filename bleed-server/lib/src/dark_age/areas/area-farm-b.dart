
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaFarmB extends DarkAgeArea {
  AreaFarmB() : super(darkAgeScenes.farmB, mapTile: MapTiles.FarmB);

  @override
  int get areaType => AreaType.Farm;
}