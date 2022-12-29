import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeForest extends DarkAgeArea {
  GameDarkAgeForest() : super(scene: darkAgeScenes.forest, mapTile: MapTiles.Forest);

  @override
  int get areaType => AreaType.Forest;
}