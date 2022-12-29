
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaMountainShrine extends DarkAgeArea {
  AreaMountainShrine() : super(scene: darkAgeScenes.mountainShrine, mapTile: MapTiles.Mountain_Shrine);

  @override
  int get areaType => AreaType.Mountains;
}