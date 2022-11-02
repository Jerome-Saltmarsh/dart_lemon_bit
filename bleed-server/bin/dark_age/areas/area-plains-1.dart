
import '../../classes/library.dart';
import '../../common/library.dart';
import '../../common/map_tiles.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class AreaPlains1 extends DarkAgeArea {

  AreaPlains1() : super(darkAgeScenes.plains_1, mapTile: MapTiles.Plains_1) {
    init();
  }

  void init(){
    characters.add(
        Npc(
          game: this,
          x: 740,
          y: 825,
          z: tileHeight,
          weapon: buildWeaponUnarmed(),
          team: 1,
          name: "Roth",
          health: 100,
          onInteractedWith: (Player player){
             print("player interacted with Roth");
          }
        )
    );
  }
}