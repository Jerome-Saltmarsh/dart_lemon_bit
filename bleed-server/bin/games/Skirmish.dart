

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/randomItem.dart';

import '../classes/Character.dart';
import '../classes/DynamicObject.dart';
import '../classes/EnvironmentObject.dart';
import '../classes/Game.dart';
import '../classes/InteractableNpc.dart';
import '../classes/Item.dart';
import '../classes/Player.dart';
import '../common/DynamicObjectType.dart';
import '../common/ItemType.dart';
import '../common/PlayerEvent.dart';
import '../common/SlotType.dart';
import '../common/ObjectType.dart';
import '../engine.dart';
import '../functions/withinRadius.dart';

class GameSkirmish extends Game {
  late final List<EnvironmentObject> _flags;
  final _time = 16 * 60 * 60;
  late final InteractableNpc storeKeeper;

  GameSkirmish() : super(engine.scenes.skirmish){
     _flags = scene.environment.where((env) => env.type == ObjectType.Flag).toList();

     storeKeeper = InteractableNpc(
         name: "Store Keeper",
         onInteractedWith: (Player player){

         },
         x: 0,
         y: 100,
         health: 100,
         weapon: SlotType.Empty
     );
     storeKeeper.invincible = true;
     npcs.add(storeKeeper);

     dynamicObjects.add(
         DynamicObject(
             type: DynamicObjectType.Pot,
             x: -1825,
             y: 2130,
             health: 10,
         )
     );

     dynamicObjects.add(
         DynamicObject(
           type: DynamicObjectType.Rock,
           x: -800,
           y: 2650,
           health: 10,
         )
     );

     dynamicObjects.add(
         DynamicObject(
           type: DynamicObjectType.Rock,
           x: -300,
           y: 3450,
           health: 10,
         )
     );

     dynamicObjects.add(
         DynamicObject(
           type: DynamicObjectType.Pot,
           x: 500,
           y: 3000,
           health: 10,
         )
     );

     dynamicObjects.add(
         DynamicObject(
           type: DynamicObjectType.Pot,
           x: 1850,
           y: 2120,
           health: 10,
         )
     );

     dynamicObjects.add(
         DynamicObject(
           type: DynamicObjectType.Chest,
           x: 0,
           y: 1000,
           health: 10,
         )
     );

     dynamicObjects.add(
         DynamicObject(
           type: DynamicObjectType.Chest,
           x: 640,
           y: 1700,
           health: 10,
         )
     );


     dynamicObjects.add(
         DynamicObject(
           type: DynamicObjectType.Chest,
           x: -1850,
           y: 2650,
           health: 10,
         )
     );
  }

  @override
  void update(){
    if (frame % 100 == 0) {
      if (numberOfAliveZombies < 10){
        spawnRandomZombie(health: 10, damage: 1, team: 1);
      }
    }

    for (final player in players) {
      const storeRadius = 100.0;
      player.storeVisible = withinRadius(player, storeKeeper, storeRadius);
    }
  }

  @override
  int getTime() {
    return _time;
  }

  Player playerJoin() {
    final location = getNextSpawnPoint();
    final player = Player(
      x: location.x,
      y: location.y,
      game: this,
      team: Teams.none,
      weapon: SlotType.Pickaxe,
    );
    final slots = player.slots;
    player.orbs.emerald = 50;
    player.orbs.ruby = 50;
    player.orbs.topaz = 50;
    slots.weapon.amount = 50;
    slots.slot1.type = SlotType.Potion_Red;
    slots.slot2.type = SlotType.Shotgun;
    slots.slot2.amount = 100;
    slots.slot3.type = SlotType.Sword_Short;
    slots.slot4.type = SlotType.Bow_Wooden;
    slots.slot4.amount = 30;
    slots.slot5.type = SlotType.Handgun;
    slots.slot5.amount = 32;
    return player;
  }

  @override
  Position getNextSpawnPoint(){
    return randomItem(_flags);
  }

  @override
  void onCharacterKilled(Character killed, dynamic by) {
    if (killed is Player) {
      killed.score = 0;
      if (by is Player) {
        by.score += 5;
      }
      return;
    }
    if (by is Player) {
      by.score++;
    }
    // final randomItemType = randomItem(ItemType.values);
    // final item = Item(type: randomItemType, x: killed.x, y: killed.y);
    // items.add(item);
  }

  @override
  bool onPlayerItemCollision(Player player, Item item){
    final slots = player.slots;

    if (item.type == ItemType.Orb_Topaz) {
      player.onPlayerEvent(PlayerEvent.Orb_Earned_Topaz);
      player.orbs.topaz++;
      player.onOrbsChanged();
      return true;
    }

    if (item.type == ItemType.Orb_Ruby) {
      player.onPlayerEvent(PlayerEvent.Orb_Earned_Ruby);
      player.orbs.ruby++;
      player.onOrbsChanged();
      return true;
    }

    if (item.type == ItemType.Orb_Emerald) {
      player.onPlayerEvent(PlayerEvent.Orb_Earned_Emerald);
      player.orbs.emerald++;
      player.onOrbsChanged();
      return true;
    }

    switch(item.type) {

      case ItemType.Health:
        if (player.health >= player.maxHealth) return false;
        player.health += 5;
        player.onPlayerEvent(PlayerEvent.Medkit);
        return true;

      case ItemType.Handgun:
        final slot = slots.findWeaponSlotByType(SlotType.Handgun);
        if (slot == null) {
          final emptySlot = slots.getEmptyWeaponSlot();
          if (emptySlot == null) return false;
          emptySlot.type = SlotType.Handgun;
          emptySlot.amount = 10;
          return true;
        }
        player.onPlayerEvent(PlayerEvent.Ammo_Acquired);
        slot.amount += 10;
        return true;

      case ItemType.Sword_Wooden:
        final emptySlot = slots.getEmptyWeaponSlot();
        if (emptySlot == null) return false;
        emptySlot.type = SlotType.Sword_Wooden;
        return true;

      case ItemType.Sword_Steel:
        final emptySlot = slots.getEmptyWeaponSlot();
        if (emptySlot == null) return false;
        emptySlot.type = SlotType.Sword_Short;
        return true;

      case ItemType.Armour_Plated:
        final emptySlot = slots.getEmptyArmourSlot();
        if (emptySlot == null) return false;
        emptySlot.type = SlotType.Armour_Padded;
        return true;

      case ItemType.Wizards_Hat:
        final emptySlot = slots.getEmptyHeadSlot();
        if (emptySlot == null) return false;
        emptySlot.type = SlotType.Magic_Hat;
        return true;

      case ItemType.Steel_Helm:
        final emptySlot = slots.getEmptyHeadSlot();
        if (emptySlot == null) return false;
        emptySlot.type = SlotType.Steel_Helmet;
        return true;

      case ItemType.Shotgun:
        final slot = slots.findWeaponSlotByType(SlotType.Shotgun);
        if (slot == null) {
          final emptySlot = slots.getEmptyWeaponSlot();
          if (emptySlot == null) return false;
          emptySlot.type = SlotType.Shotgun;
          emptySlot.amount = 10;
          return true;
        }
        player.onPlayerEvent(PlayerEvent.Ammo_Acquired);
        slot.amount += 10;
        return true;

      default:
        return true;
    }
  }
}