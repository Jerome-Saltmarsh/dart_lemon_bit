
import 'package:bleed_server/gamestream.dart';
import '../dark_age_scenes.dart';
import 'dark_age_area.dart';

class Area_OldVillage extends DarkAgeArea {

  @override
  int get areaType => AreaType.Old_Village;

  Area_OldVillage() : super(scene: darkAgeScenes.plains_1, mapTile: MapTiles.Plains_1) {
    init();
  }

  void init(){
    characters.add(
        AI(
          characterType: CharacterType.Template,
          x: 1000,
          y: 825,
          z: Node_Height,
          damage: 3,
          weaponType: ItemType.Empty,
          team: TeamType.Good,
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
            team: TeamType.Good,
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