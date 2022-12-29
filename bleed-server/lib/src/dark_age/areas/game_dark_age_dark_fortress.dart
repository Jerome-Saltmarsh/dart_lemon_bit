
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class GameDarkAgeDarkFortress extends DarkAgeArea {
  GameDarkAgeDarkFortress() : super(scene: darkAgeScenes.darkFortress, mapTile: -1);

  @override
  int get areaType => AreaType.Dark_Fortress;
}