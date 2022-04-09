import 'package:bleed_server/firestoreClient/firestoreService.dart';
import 'package:lemon_math/Vector2.dart';

import '../common/AbilityMode.dart';
import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/GemSpawn.dart';
import '../common/OrbType.dart';
import '../common/PlayerEvent.dart';
import '../common/SlotType.dart';
import '../common/SlotTypeCategory.dart';
import '../constants/no_squad.dart';
import '../engine.dart';
import '../functions/generateName.dart';
import '../utilities.dart';
import 'Ability.dart';
import 'Character.dart';
import 'Collider.dart';
import 'Game.dart';

class Player extends Character {
  final gameEventIds = <int, bool>{};
  final events = <PlayerEvent>[];
  final gemSpawns = <GemSpawn>[];
  final slots = Slots();
  final orbs = Orbs();
  var score = 0;
  var sceneChanged = false;
  var characterState = stateIdle;
  Account? account;
  /// How many frames have elapsed since the server received a message from this client
  int lastUpdateFrame = 0;
  int frameOfDeath = -1;
  int pointsRecord = 0;
  int textDuration = 0;
  int handgunDamage = 10;
  int experience = 0;
  int level = 1;
  int abilityPoints = 0;
  int _magic = 0;
  int maxMagic = 100;
  int magicRegen = 1;
  int healthRegen = 1;
  String message = "";
  String text = "";
  String name = generateName();
  Game game;
  bool storeVisible = false;
  bool skipUpdate = false;
  double mouseX = 0;
  double mouseY = 0;
  double screenLeft = 0;
  double screenTop = 0;
  double screenRight = 0;
  double screenBottom = 0;
  Collider? aimTarget; // the currently highlighted character
  Vector2? target;
  Vector2 runTarget = Vector2(0, 0);

  void attainOrb(OrbType orb){
    switch(orb) {
      case OrbType.Topaz:
        orbs.topaz++;
        dispatch(PlayerEvent.Orb_Earned_Topaz);
        return;
      case OrbType.Ruby:
        orbs.ruby++;
        return;
      case OrbType.Emerald:
        orbs.emerald++;
        return;
    }
  }

  int get magic => _magic;

  double get magicPercentage {
    if (_magic == 0) return 0;
    if (maxMagic == 0) return 0;
    return _magic / maxMagic;
  }

  set magic(int value){
    _magic = clampInt(value, 0, maxMagic);
  }

  void dispatch(PlayerEvent event){
    events.add(event);
  }

  Player({
    required this.game,
    required SlotType weapon,
    double x = 0,
    double y = 0,
    int team = noSquad,
    int magic = 10,
    int health = 10,
    AI? ai,
  }) : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            health: health,
            speed: 3.5,
            team: team,
            ai: ai,
            weapon: weapon,

  ){
    maxMagic = magic;
    _magic = maxMagic;
    engine.onPlayerCreated(this);
  }

  void setStateChangingWeapons(){
    dispatch(PlayerEvent.Item_Equipped); // TODO
    game.setCharacterState(this, stateChanging);
  }

  void unequip(SlotTypeCategory slotTypeCategory){
    final emptySlot = slots.getEmptySlot();
    if (emptySlot == null) return;

    switch(slotTypeCategory) {
      case SlotTypeCategory.Weapon:
        if (weapon.isEmpty) return;
        final weaponSlot = slots.weapon;
        emptySlot.swapWith(weaponSlot);
        onUnequipped(weapon);
        setStateChangingWeapons();
        break;
      case SlotTypeCategory.Armour:
        final armour = slots.armour;
        if (armour.isEmpty) return;
        onUnequipped(armour.type);
        emptySlot.swapWith(armour);
        setStateChangingWeapons();
        break;
      case SlotTypeCategory.Helm:
        final helm = slots.helm;
        if (helm.isEmpty) return;
        onUnequipped(helm.type);
        emptySlot.swapWith(helm);
        setStateChangingWeapons();
        break;
      case SlotTypeCategory.Pants:
        break;
    }
  }

  void acquire(SlotType slotType) {
    if (slotType.isWeapon) {
      final slot = slots.getEmptyWeaponSlot();
      if (slot == null) return;
      dispatch(PlayerEvent.Item_Purchased);
      setStateChangingWeapons();
      slot.type = slotType;
      slot.amount = 10;
      onEquipped(slotType);
      return;
    }

    if (slotType.isArmour) {
      final slot = slots.getEmptyArmourSlot();
      if (slot == null) return;
      dispatch(PlayerEvent.Item_Purchased);
      setStateChangingWeapons();
      slot.type = slotType;
      onEquipped(slotType);
      return;
    }
    if (slotType.isHelm) {
      final slot = slots.getEmptyHeadSlot();
      if (slot == null) return;
      dispatch(PlayerEvent.Item_Purchased);
      setStateChangingWeapons();
      slot.type = slotType;
      onEquipped(slotType);
    }

    final emptySlot = slots.getEmptySlot();
    if (emptySlot == null) return;
    dispatch(PlayerEvent.Item_Purchased);
    setStateChangingWeapons();
    emptySlot.type = slotType;
    if (slotType.isItem){
      onEquipped(slotType);
    }
    return;
  }

  void useSlot(int index) {
      if (deadOrBusy) return;
      if (index < 0) return;
      if (index > 6) return;

      final slot = slots.getSlotAtIndex(index);
      if (slot.isEmpty) return;
      final slotType = slot.type;

      if (slotType.isWeapon) {
        final currentWeapon = slots.weapon;
        slots.weapon = slot;
        slots.assignSlotAtIndex(index, currentWeapon);
        setStateChangingWeapons();
        return;
      }

      if (slotType.isArmour) {
        final currentArmourType = slots.armour.type;
        slots.armour.swapWith(slot);
        onEquipped(slotType);
        onUnequipped(currentArmourType);
        setStateChangingWeapons();
      }

      if (slotType.isHelm) {
        final currentArmourType = slots.helm.type;
        slots.helm.swapWith(slot);
        onEquipped(slotType);
        onUnequipped(currentArmourType);
        setStateChangingWeapons();
      }

      if (slotType == SlotType.Spell_Tome_Fireball) {
        final cost = 5;
        if (magic < cost) return;
        ability = Ability(type: AbilityType.Fireball,
            level: 1,
            cost: cost,
            range: 250,
            cooldown: 100,
            mode: AbilityMode.Targeted);
        return;
      }

      if (slotType == SlotType.Spell_Tome_Ice_Ring) {
        final cost = 5;
        if (magic < cost) return;
        magic -= cost;
        if (!weapon.isStaff) {
          final index = slots.getSlotIndexWhere(isStaff);
          if (index == null) return;
          useSlot(index);
        }
        game.spawnFreezeRing(src: this);
        setStateChangingWeapons();
        return;
      }

      if (slotType == SlotType.Spell_Tome_Split_Arrow) {
        final cost = 5;
        if (magic < cost) return;
        if (!weapon.isBow){
           final bowIndex = slots.getSlotIndexWhere(isBow);
           if (bowIndex == null) return;
           useSlot(bowIndex);
        }

        ability = Ability(type: AbilityType.Split_Arrow,
            level: 1,
            cost: cost,
            range: 250,
            cooldown: 100,
            mode: AbilityMode.Directed);
        return;
      }

      if (slotType == SlotType.Potion_Red) {
        health = maxHealth;
        slots.assignSlotTypeAtIndex(index, SlotType.Empty);
        setStateChangingWeapons();
        dispatch(PlayerEvent.Drink_Potion);
      }

      if (slotType == SlotType.Potion_Blue) {
        magic = maxMagic;
        slots.assignSlotTypeAtIndex(index, SlotType.Empty);
        setStateChangingWeapons();
        dispatch(PlayerEvent.Drink_Potion);
      }
  }

  void sellSlot(int index){
    final slotAtIndex = slots.getSlotTypeAtIndex(index);
    if (slotAtIndex.isEmpty) return;
    slots.assignSlotTypeAtIndex(index, SlotType.Empty);
    dispatch(PlayerEvent.Item_Sold);
  }
}

class Slot {
  var type = SlotType.Empty;
  var amount = -1;

  bool get isEmpty => type.isEmpty;

  bool isType(SlotType value){
    return type == value;
  }

  void swapWith(Slot other){
    final otherType = other.type;
    final otherAmount = other.amount;
    other.type = type;
    other.amount = amount;
    type = otherType;
    amount = otherAmount;
  }
}

class Slots {
  var weapon = Slot();
  var armour = Slot();
  var helm = Slot();

  var slot1 = Slot();
  var slot2 = Slot();
  var slot3 = Slot();
  var slot4 = Slot();
  var slot5 = Slot();
  var slot6 = Slot();

  int? getSlotIndexWhere(bool Function(SlotType slotType) where){
     if (where(slot1.type)) return 1;
     if (where(slot2.type)) return 2;
     if (where(slot3.type)) return 3;
     if (where(slot4.type)) return 4;
     if (where(slot5.type)) return 5;
     if (where(slot6.type)) return 6;
     return null;
  }

  Slot getSlotAtIndex(int index) {
    switch (index) {
      case 1:
        return slot1;
      case 2:
        return slot2;
      case 3:
        return slot3;
      case 4:
        return slot4;
      case 5:
        return slot5;
      case 6:
        return slot6;
      default:
        throw Exception("$index is not a valid slot index (1 - 6 inclusive)");
    }
  }

  SlotType getSlotTypeAtIndex(int index){
    return getSlotAtIndex(index).type;
  }

  void assignSlotAtIndex(int index, Slot value){
    switch(index){
      case 1:
        slot1 = value;
        break;
      case 2:
        slot2 = value;
        break;
      case 3:
        slot3 = value;
        break;
      case 4:
        slot4 = value;
        break;
      case 5:
        slot5 = value;
        break;
      case 6:
        slot6 = value;
        break;
      default:
        throw Exception("cannot assign slot $index it out of bounds");
    }
  }

  void assignSlotTypeAtIndex(int index, SlotType type){
    getSlotAtIndex(index).type = type;
  }

  bool get emptySlotAvailable => getEmptySlot() != null;

  Slot? getEmptySlot(){
    return findSlotByType(SlotType.Empty);
  }

  Slot? getEmptyWeaponSlot(){
    if (weapon.isEmpty) return weapon;
    return findSlotByType(SlotType.Empty);
  }

  Slot? getEmptyArmourSlot(){
    if (armour.isEmpty) return armour;
    return findSlotByType(SlotType.Empty);
  }

  Slot? getEmptyHeadSlot(){
    if (helm.isEmpty) return helm;
    return findSlotByType(SlotType.Empty);
  }

  Slot? findWeaponSlotByType(SlotType type){
    if (weapon.isType(type)) return weapon;
    if (slot1.isType(type)) return slot1;
    if (slot2.isType(type)) return slot2;
    if (slot3.isType(type)) return slot3;
    if (slot4.isType(type)) return slot4;
    if (slot5.isType(type)) return slot5;
    if (slot6.isType(type)) return slot6;
    return null;
  }


  Slot? findSlotByType(SlotType type){
    if (slot1.isType(type)) return slot1;
    if (slot2.isType(type)) return slot2;
    if (slot3.isType(type)) return slot3;
    if (slot4.isType(type)) return slot4;
    if (slot5.isType(type)) return slot5;
    if (slot6.isType(type)) return slot6;
    return null;
  }

  bool assignToEmpty(SlotType type){
    final empty = getEmptySlot();
    if (empty == null) return false;
    empty.type = type;
    return true;
  }
}

class Orbs {
  int topaz = 0;
  int ruby = 0;
  int emerald = 0;
}

extension PlayerProperties on Player {

  bool get isHuman => type == CharacterType.Human;

  bool get unarmed => weapon.isEmpty;

  void onEquipped(SlotType slotType){
    maxHealth += slotType.health;
    health = clampInt(health + slotType.health, 1, maxHealth);
    maxMagic += slotType.magic;
    magic = clampInt(magic + slotType.magic, 1, maxMagic);
  }

  void onUnequipped(SlotType slotType){
    maxHealth -= slotType.health;
    health = clampInt(health - slotType.health, 1, maxHealth);
    maxMagic -= slotType.magic;
    magic = clampInt(magic - slotType.magic, 1, maxMagic);
  }
}
