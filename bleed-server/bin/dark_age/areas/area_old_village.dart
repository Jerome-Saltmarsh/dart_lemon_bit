
import '../../classes/library.dart';
import '../../common/library.dart';
import '../../functions/move_player_to_crystal.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class DarkAgeTeam {
  static const Good = 1;
  static const Bad = 2;
  static const Bandits = 3;
}

class Area_OldVillage extends DarkAgeArea {

  @override
  int get areaType => AreaType.Old_Village;

  Area_OldVillage() : super(darkAgeScenes.plains_1, mapTile: MapTiles.Plains_1) {
    init();
  }

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        team: DarkAgeTeam.Good,
        weaponType: ItemType.Weapon_Ranged_Handgun,
        health: 20,
    );
    player.bodyType = ItemType.Body_Tunic_Padded;
    player.legsType = ItemType.Legs_Blue;
    player.headType = ItemType.Head_Steel_Helm;
    movePlayerToCrystal(player);
    player.setCharacterStateSpawning();
    player.inventory[0] = ItemType.Weapon_Ranged_Handgun;
    player.inventory[1] = ItemType.Weapon_Ranged_Shotgun;
    player.inventory[3] = ItemType.Head_Wizards_Hat;
    player.inventory[4] = ItemType.Body_Shirt_Cyan;
    player.inventory[5] = ItemType.Legs_Brown;
    player.inventory[6] = ItemType.Recipe_Staff_Of_Fire;
    player.inventory[7] = ItemType.Resource_Gun_Powder;
    player.inventory[8] = ItemType.Consumables_Meat;
    player.inventory[9] = ItemType.Consumables_Apple;
    player.inventoryQuantity[7] = 100;
    player.belt1_itemType = ItemType.Weapon_Ranged_Handgun;
    player.equippedWeaponIndex = ItemType.Belt_1;
    player.inventoryDirty = true;
    return player;
  }

  void init(){
    characters.add(
        Npc(
          game: this,
          x: 1000,
          y: 825,
          z: tileHeight,
          weaponType: ItemType.Empty,
          team: DarkAgeTeam.Good,
          name: "Roth",
          health: 100,
          onInteractedWith: (Player player) {
             player.interact(message: 'salutations', responses: {
               'introduction': () {
                 player.interact(message: 'the name is roth. i am the mayor of this town');
               },
               'tutorial': () {
                 player.interact(
                    message: 'what would you like to know?',
                 );
               },
               'trade': () {
                 player.setStoreItems(const [
                    ItemType.Legs_Brown,
                    ItemType.Legs_Blue,
                    ItemType.Resource_Gun_Powder,
                    ItemType.Resource_Arrow,
                    ItemType.Consumables_Apple,
                    ItemType.Consumables_Meat,
                 ]);
               },
               'never mind': player.endInteraction
             });
          }
        )
          ..bodyType = ItemType.Body_Tunic_Padded
          ..legsType = ItemType.Legs_Blue
          ..headType = ItemType.Head_Steel_Helm

    );

    characters.add(
        Npc(
            game: this,
            x: 1020,
            y: 1225,
            z: tileHeight,
            weaponType: ItemType.Empty,
            team: DarkAgeTeam.Good,
            name: "Smith",
            health: 100,
            onInteractedWith: (Player player) {
              player.interact(message: 'welcome', responses: {
                'introduction': () {
                  player.interact(message: 'the name is Bastian. I am the smith. Bring me your materials and recipe I can craft it into an item for you. For a fee of course');
                },
                'hints': () {
                  player.interact(
                    message: 'what would you like to know?',
                  );
                },
                'craft': () {
                  player.interactMode = InteractMode.Craft;
                },
                'never mind': player.endInteraction
              });
            }
        )
          ..bodyType = ItemType.Body_Tunic_Padded
          ..legsType = ItemType.Legs_Blue
          ..headType = ItemType.Head_Steel_Helm

    );
  }
}