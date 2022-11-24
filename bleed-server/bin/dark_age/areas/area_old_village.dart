
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
        weaponType: ItemType.Weapon_Handgun_Flint_Lock_Old,
        health: 20,
    );
    player.bodyType = ItemType.Body_Tunic_Padded;
    player.legsType = ItemType.Legs_Blue;
    player.headType = ItemType.Head_Steel_Helm;
    movePlayerToCrystal(player);
    player.setCharacterStateSpawning();

    player.inventoryAdd1(itemType: ItemType.Weapon_Ranged_Shotgun);
    player.inventoryAdd(itemType: ItemType.Resource_Gun_Powder, itemQuantity: 100);
    player.inventoryAdd(itemType: ItemType.Resource_Scrap_Metal, itemQuantity: 100);
    player.inventoryAdd(itemType: ItemType.Resource_Gold, itemQuantity: 100);
    player.inventoryAdd1(itemType: ItemType.Trinket_Ring_of_Damage);
    player.inventoryAdd1(itemType: ItemType.Trinket_Ring_of_Health);
    player.inventoryAdd1(itemType: ItemType.Weapon_Melee_Sword);
    player.inventoryAdd1(itemType: ItemType.Weapon_Rifle_Arquebus);
    player.inventoryAdd1(itemType: ItemType.Weapon_Rifle_Jager);
    player.inventoryAdd1(itemType: ItemType.Weapon_Rifle_Musket);
    player.inventorySet(index: ItemType.Belt_1, itemType: ItemType.Weapon_Handgun_Flint_Lock_Old, itemQuantity: 1);
    player.equippedWeaponIndex = ItemType.Belt_1;
    player.inventoryDirty = true;
    player.refreshStats();
    player.health = player.maxHealth;
    return player;
  }

  void init(){
    characters.add(
        Npc(
          game: this,
          x: 1000,
          y: 825,
          z: Node_Height,
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
                    ItemType.Body_Shirt_Cyan,
                    ItemType.Body_Shirt_Blue,
                    ItemType.Body_Tunic_Padded,
                    ItemType.Resource_Gun_Powder,
                    ItemType.Resource_Arrow,
                    ItemType.Consumables_Apple,
                    ItemType.Consumables_Meat,
                    ItemType.Weapon_Handgun_Flint_Lock_Old,
                    ItemType.Weapon_Handgun_Flint_Lock,
                    ItemType.Weapon_Handgun_Flint_Lock_Superior,
                    ItemType.Weapon_Handgun_Blunderbuss,
                    ItemType.Weapon_Handgun_Revolver,
                    ItemType.Weapon_Handgun_Glock,
                    ItemType.Weapon_Ranged_Bow,
                    ItemType.Weapon_Rifle_Arquebus,
                    ItemType.Weapon_Rifle_Musket,
                    ItemType.Weapon_Rifle_Jager,
                    ItemType.Weapon_Rifle_AK_47,
                    ItemType.Weapon_Rifle_M4,
                    ItemType.Weapon_Rifle_Steyr,
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
            z: Node_Height,
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