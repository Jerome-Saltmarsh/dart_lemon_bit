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

  late Function onUpdated;
  late Function onOrbsChanged;
  late Function onSlotsChanged;
  late Function(PlayerEvent value) onPlayerEvent;
  late Function(int type, double x, double y, double angle) onGameEvent;

  void attainOrb(OrbType orb){
    switch(orb) {
      case OrbType.Topaz:
        orbs.topaz++;
        onPlayerEvent(PlayerEvent.Orb_Earned_Topaz);
        break;
      case OrbType.Ruby:
        orbs.ruby++;
        break;
      case OrbType.Emerald:
        orbs.emerald++;
        break;
    }
    onOrbsChanged();
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

  Player({
    required this.game,
    required int weapon,
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
    onPlayerEvent(PlayerEvent.Item_Equipped); // TODO
    game.setCharacterState(this, stateChanging);
  }

  void unequip(SlotTypeCategory slotTypeCategory){
    final emptySlot = slots.getEmptySlot();
    if (emptySlot == null) return;

    switch(slotTypeCategory) {
      case SlotTypeCategory.Weapon:
        if (weapon == SlotType.Empty) return;
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

  void acquire(int slotType) {
    if (SlotType.isWeapon(slotType)) {
      final slot = slots.getEmptyWeaponSlot();
      if (slot == null) return;
      onPlayerEvent(PlayerEvent.Item_Purchased);
      setStateChangingWeapons();
      slot.type = slotType;
      slot.amount = 10;
      onEquipped(slotType);
      return;
    }

    if (SlotType.isArmour(slotType)) {
      final slot = slots.getEmptyArmourSlot();
      if (slot == null) return;
      onPlayerEvent(PlayerEvent.Item_Purchased);
      setStateChangingWeapons();
      slot.type = slotType;
      onEquipped(slotType);
      return;
    }
    if (SlotType.isHelm(slotType)) {
      final slot = slots.getEmptyHeadSlot();
      if (slot == null) return;
      onPlayerEvent(PlayerEvent.Item_Purchased);
      setStateChangingWeapons();
      slot.type = slotType;
      onEquipped(slotType);
    }

    final emptySlot = slots.getEmptySlot();
    if (emptySlot == null) return;
    onPlayerEvent(PlayerEvent.Item_Purchased);
    setStateChangingWeapons();
    emptySlot.type = slotType;
    if (SlotType.isItem(slotType)){
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

      if (SlotType.isWeapon(slotType)) {
        final currentWeapon = slots.weapon;
        slots.weapon = slot;
        slots.assignSlotAtIndex(index, currentWeapon);
        onSlotsChanged();
        setStateChangingWeapons();
        return;
      }

      if (SlotType.isArmour(slotType)) {
        final currentArmourType = slots.armour.type;
        slots.armour.swapWith(slot);
        onEquipped(slotType);
        onUnequipped(currentArmourType);
        setStateChangingWeapons();
        onSlotsChanged();
      }

      if (SlotType.isHelm(slotType)) {
        final currentArmourType = slots.helm.type;
        slots.helm.swapWith(slot);
        onEquipped(slotType);
        onUnequipped(currentArmourType);
        setStateChangingWeapons();
        onSlotsChanged();
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
        if (!SlotType.isStaff(weapon)) {
          final index = slots.getSlotIndexWhere(SlotType.isStaff);
          if (index == null) return;
          useSlot(index);
        }
        game.spawnFreezeRing(src: this);
        setStateChangingWeapons();
        onSlotsChanged();
        return;
      }

      if (slotType == SlotType.Spell_Tome_Split_Arrow) {
        final cost = 5;
        if (magic < cost) return;
        if (!SlotType.isBow(weapon)){
           final bowIndex = slots.getSlotIndexWhere(SlotType.isBow);
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
        onPlayerEvent(PlayerEvent.Drink_Potion);
        onSlotsChanged();
      }

      if (slotType == SlotType.Potion_Blue) {
        magic = maxMagic;
        slots.assignSlotTypeAtIndex(index, SlotType.Empty);
        setStateChangingWeapons();
        onPlayerEvent(PlayerEvent.Drink_Potion);
        onSlotsChanged();
      }
  }

  void sellSlot(int index){
    final slotAtIndex = slots.getSlotTypeAtIndex(index);
    if (slotAtIndex == SlotType.Empty) return;
    slots.assignSlotTypeAtIndex(index, SlotType.Empty);
    onPlayerEvent(PlayerEvent.Item_Sold);
    onSlotsChanged();
  }
}

class Slot {
  var type = SlotType.Empty;
  var amount = -1;

  bool get isEmpty => type == SlotType.Empty;

  bool isType(int value){
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

  int? getSlotIndexWhere(bool Function(int slotType) where){
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

  int getSlotTypeAtIndex(int index){
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

  void assignSlotTypeAtIndex(int index, int type){
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

  Slot? findWeaponSlotByType(int type){
    if (SlotType.isWeapon(type)) return weapon;
    if (slot1.isType(type)) return slot1;
    if (slot2.isType(type)) return slot2;
    if (slot3.isType(type)) return slot3;
    if (slot4.isType(type)) return slot4;
    if (slot5.isType(type)) return slot5;
    if (slot6.isType(type)) return slot6;
    return null;
  }


  Slot? findSlotByType(int type){
    if (slot1.isType(type)) return slot1;
    if (slot2.isType(type)) return slot2;
    if (slot3.isType(type)) return slot3;
    if (slot4.isType(type)) return slot4;
    if (slot5.isType(type)) return slot5;
    if (slot6.isType(type)) return slot6;
    return null;
  }

  bool assignToEmpty(int type){
    final empty = getEmptySlot();
    if (empty == null) return false;
    empty.type = type;
    return true;
  }
}

class Orbs {
  var topaz = 0;
  var ruby = 0;
  var emerald = 0;
}

extension PlayerProperties on Player {

  bool get isHuman => type == CharacterType.Human;

  bool get unarmed => weapon == SlotType.Empty;

  void onEquipped(int slotType){
    final healthIncrease = SlotType.getHealth(slotType);
    maxHealth += healthIncrease;
    health = clampInt(health + healthIncrease, 1, maxHealth);
    final magicIncrease = SlotType.getMagic(slotType);
    maxMagic += magicIncrease;
    magic = clampInt(magic + magicIncrease, 1, maxMagic);
  }

  void onUnequipped(int slotType){
    final healthAmount = SlotType.getHealth(slotType);
    maxHealth -= healthAmount;
    health = clampInt(health - healthAmount, 1, maxHealth);
    final magicAmount = SlotType.getMagic(slotType);
    maxMagic -= magicAmount;
    magic = clampInt(magic - magicAmount, 1, maxMagic);
  }
}
