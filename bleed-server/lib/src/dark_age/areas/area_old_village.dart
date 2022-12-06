
import 'package:bleed_server/gamestream.dart';
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

  // @override
  // Player spawnPlayer() {
  //   final player = Player(
  //       game: this,
  //   );
  //   player.bodyType = ItemType.Body_Tunic_Padded;
  //   player.legsType = ItemType.Legs_Blue;
  //   player.headType = ItemType.Head_Steel_Helm;
  //   movePlayerToCrystal(player);
  //   player.setCharacterStateSpawning();
  //
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Ranged_Shotgun);
  //   player.inventoryAdd(itemType: ItemType.Resource_Gun_Powder, itemQuantity: 100);
  //   player.inventoryAdd(itemType: ItemType.Resource_Round_9mm, itemQuantity: 100);
  //   player.inventoryAdd(itemType: ItemType.Resource_Round_Rifle, itemQuantity: 100);
  //   player.inventoryAdd(itemType: ItemType.Resource_Round_Shotgun, itemQuantity: 100);
  //   player.inventoryAdd(itemType: ItemType.Resource_Round_50cal, itemQuantity: 100);
  //   player.inventoryAdd(itemType: ItemType.Resource_Scrap_Metal, itemQuantity: 100);
  //   player.inventoryAdd(itemType: ItemType.Resource_Scrap_Metal, itemQuantity: 120);
  //   player.inventoryAdd(itemType: ItemType.Resource_Scrap_Metal, itemQuantity: 320);
  //   player.inventoryAdd(itemType: ItemType.Resource_Scrap_Metal, itemQuantity: 220);
  //   player.inventoryAdd(itemType: ItemType.Resource_Scrap_Metal, itemQuantity: 450);
  //   player.inventoryAdd(itemType: ItemType.Resource_Gold, itemQuantity: 100);
  //   player.inventoryAddMax(itemType: ItemType.Trinket_Ring_of_Damage);
  //   player.inventoryAddMax(itemType: ItemType.Trinket_Ring_of_Health);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Melee_Sword);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Arquebus);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Jager);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Musket);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_Sniper);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Handgun_Glock);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Handgun_Desert_Eagle);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_AK_47);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Rifle_M4);
  //   player.inventoryAddMax(itemType: ItemType.Weapon_Melee_Knife);
  //   player.inventoryAdd(itemType: ItemType.Weapon_Thrown_Grenade, itemQuantity: 10);
  //   player.inventoryAdd(itemType: ItemType.Weapon_Flamethrower, itemQuantity: 500);
  //   player.inventoryAdd(itemType: ItemType.Weapon_Special_Bazooka, itemQuantity: 500);
  //   player.inventoryAdd(itemType: ItemType.Weapon_Smg_Mp5, itemQuantity: 200);
  //   player.inventoryAdd(itemType: ItemType.Weapon_Special_Minigun, itemQuantity: 1000);
  //   player.inventoryAdd(itemType: ItemType.Weapon_Handgun_Revolver, itemQuantity: 1000);
  //   player.inventoryAdd(itemType: ItemType.Head_Swat);
  //   player.inventoryAdd(itemType: ItemType.Body_Swat);
  //   player.inventoryAdd(itemType: ItemType.Legs_Swat);
  //   player.inventorySet(index: ItemType.Belt_1, itemType: ItemType.Weapon_Handgun_Flint_Lock_Old, itemQuantity: 1);
  //   player.equippedWeaponIndex = ItemType.Belt_1;
  //   player.inventoryDirty = true;
  //   player.refreshStats();
  //   player.health = player.maxHealth;
  //   return player;
  // }

  void init(){
    characters.add(
        AI(
          characterType: CharacterType.Template,
          x: 1000,
          y: 825,
          z: Node_Height,
          damage: 3,
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
                    ItemType.Weapon_Thrown_Grenade,
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
        AI(
            damage: 1,
            characterType: CharacterType.Template,
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