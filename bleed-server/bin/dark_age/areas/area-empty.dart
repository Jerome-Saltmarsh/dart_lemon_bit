
import '../../classes/player.dart';
import '../../common/map_tiles.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaEmpty extends DarkAgeArea {
  AreaEmpty() : super(darkAgeScenes.farmA, mapTile: MapTiles.FarmA);

  @override
  void customOnPlayerJoined(Player player) {
     throw Exception("Player cannot join empty area");
  }
}