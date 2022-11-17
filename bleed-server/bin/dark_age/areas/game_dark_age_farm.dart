
import '../../classes/library.dart';
import '../../common/library.dart';
import '../../functions/move_player_to_crystal.dart';
import '../dark_age_scenes.dart';
import 'area_old_village.dart';
import 'dark_age_area.dart';

class GameDarkAgeFarm extends DarkAgeArea {
  GameDarkAgeFarm() : super(darkAgeScenes.farm, mapTile: MapTiles.Farm) {
    addNpc(
      headType: ItemType.Head_Rogues_Hood,
      armour: ItemType.Body_Tunic_Padded,
      pants: ItemType.Legs_Brown,
      team: DarkAgeTeam.Bandits,
        weaponType: ItemType.Empty,
        name: "Magellan",
        row: 28,
        column: 21,
        z: 3,
        onInteractedWith: (player) =>
           player.interact(message: "Its risky to go out into the wilderness but that's where one finds the loots"),
        wanderRadius: 50,
    );

    addNpc(
      headType: ItemType.Head_Rogues_Hood,
      armour: ItemType.Body_Tunic_Padded,
      pants: ItemType.Legs_Brown,
      team: DarkAgeTeam.Bandits,
      weaponType: ItemType.Empty,
      name: "Sammy",
      row: 28,
      column: 15,
      z: 3,
      onInteractedWith: (player){
        player.interact(message: "Hi Dear");
      },
      wanderRadius: 5,
    );
  }

  @override
  void customInitPlayer(Player player) {
    movePlayerToCrystal(player);
    player.setCharacterStateSpawning();
    // player.weapon = buildWeaponShotgun();

    player.interact(
        message: "Welcome to Dark-Age! \n\nUse the W,A,S,D keys to run \nLeft and right mouse click to attack and interact",
        responses: {
          "Okay!": player.endInteraction,
        }
    );
  }

  @override
  void customOnCharacterKilled(dynamic target, dynamic src){
     if (src is Player){
        if (src.questInProgress(Quest.Garry_Kill_Farm_Zombies)){
        }
     }
  }

  @override
  int get areaType => AreaType.Farm;
}