
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaTown extends DarkAgeArea {
  AreaTown() : super(darkAgeScenes.town, mapTile: MapTiles.Town);

  @override
  int get areaType => AreaType.Town;
}