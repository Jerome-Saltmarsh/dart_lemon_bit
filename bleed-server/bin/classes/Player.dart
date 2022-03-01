import 'package:lemon_math/Vector2.dart';

import '../common/AbilityMode.dart';
import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/OrbType.dart';
import '../common/PlayerEvent.dart';
import '../common/Quests.dart';
import '../common/SlotType.dart';
import '../common/SlotTypeCategory.dart';
import '../common/WeaponType.dart';
import '../constants/no_squad.dart';
import '../engine.dart';
import '../functions/generateName.dart';
import '../settings.dart';
import '../utilities.dart';
import 'Ability.dart';
import 'Character.dart';
import 'Entity.dart';
import 'Game.dart';
import 'Weapon.dart';

const _defaultMaxMagic = 10;

class Player extends Character with Entity {
  String name = generateName();
  int lastUpdateFrame = 0;
  int frameOfDeath = -1;
  int pointsRecord = 0;
  String message = "";
  String text = "";
  int textDuration = 0;
  MainQuest questMain = MainQuest.Introduction;
  bool sceneChanged = false;
  Game game;
  int handgunDamage = 10;
  int experience = 0;
  int level = 1;
  int abilityPoints = 0;
  int _magic = 0;
  int maxMagic = 100;
  int magicRegen = 1;
  int healthRegen = 1;

  double mouseX = 0;
  double mouseY = 0;

  final List<PlayerEvent> events = [];
  CharacterState characterState = CharacterState.Idle;
  Ability ability1 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0, mode: AbilityMode.None);
  Ability ability2 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0, mode: AbilityMode.None);
  Ability ability3 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0, mode: AbilityMode.None);
  Ability ability4 = Ability(type: AbilityType.None, level: 0, cost: 0, range: 0, cooldown: 0, mode: AbilityMode.None);
  bool abilitiesDirty = true;

  final slots = _PlayerSlots();

  final orbs = _Orbs();

  Character? _aimTarget; // the currently highlighted character

  Character? get aimTarget => _aimTarget;

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

  set aimTarget(Character? value){
    if (value == null){
      _aimTarget = null;
      return;
    }
    if (value.team == team){
      throw Exception("cannot aim at same team");
    }
    if (value.dead){
      throw Exception("cannot aim at dead target");
    }
    if (!value.active){
      throw Exception("cannot aim at inactive target");
    }
    _aimTarget = value;
  }

  int get magic => _magic;

  set magic(int value){
    _magic = clampInt(value, 0, maxMagic);
  }

  void dispatch(PlayerEvent event){
    events.add(event);
  }

  Player({
    required this.game,
    double x = 0,
    double y = 0,
    int team = noSquad,
    int magic = _defaultMaxMagic,
    int health = 10,
    AI? ai,
  }) : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            health: health,
            speed: settings.playerSpeed,
            team: team,
            ai: ai,
  ){
    maxMagic = magic;
    _magic = maxMagic;
    engine.onPlayerCreated(this);
  }

  void setStateChangingWeapons(){
    game.setCharacterState(this, CharacterState.Changing);
  }

  void unequip(SlotTypeCategory slotTypeCategory){
    if (!slots.emptySlotAvailable) return;
    dispatch(PlayerEvent.Item_Equipped);

    switch(slotTypeCategory) {
      case SlotTypeCategory.Weapon:
        if (slots.weapon.isEmpty) return;
        slots.assignToEmpty(slots.weapon);
        onUnequipped(slots.weapon);
        slots.weapon = SlotType.Empty;
        setStateChangingWeapons();
        break;
      case SlotTypeCategory.Armour:
        final previousArmour = slots.armour;
        if (previousArmour.isEmpty) return;
        slots.assignToEmpty(previousArmour);
        onUnequipped(slots.armour);
        slots.armour = SlotType.Empty;
        setStateChangingWeapons();
        break;
      case SlotTypeCategory.Helm:
        if (slots.helm.isEmpty) return;
        slots.assignToEmpty(slots.helm);
        onUnequipped(slots.helm);
        slots.helm = SlotType.Empty;
        setStateChangingWeapons();
        break;
      case SlotTypeCategory.Pants:
        break;
    }
  }

  void acquire(SlotType slotType) {
    if (!slots.emptySlotAvailable) return;
    dispatch(PlayerEvent.Item_Purchased);
    setStateChangingWeapons();
    if (slotType.isWeapon) {
      if (slots.weapon.isEmpty){
        slots.weapon = slotType;
        onEquipped(slotType);
        return;
      }
    }
    if (slotType.isArmour) {
      if (slots.armour.isEmpty) {
        slots.armour = slotType;
        onEquipped(slotType);
        return;
      }
    }
    if (slotType.isHelm) {
      if (slots.helm.isEmpty) {
        slots.helm = slotType;
        onEquipped(slotType);
        return;
      }
    }
    slots.assignToEmpty(slotType);
    if (slotType.isItem){
      onEquipped(slotType);
    }
  }

  void useSlot(int index) {
      if (deadOrBusy) return;
      if (index < 0) return;
      if (index > 6) return;

      final slot = slots.getSlotTypeAtIndex(index);
      if (slot.isEmpty) return;

      if (slot.isWeapon){
        if (slot == slots.weapon) return;
        final currentWeapon = slots.weapon;
        slots.weapon = slot;
        slots.assignSlotAtIndex(index, currentWeapon);
        setStateChangingWeapons();
        dispatch(PlayerEvent.Item_Equipped);
        return;
      }

      if (slot.isArmour){
        final previousArmour = slots.armour;
        slots.armour = slot;
        onEquipped(slot);
        onUnequipped(previousArmour);
        slots.assignSlotAtIndex(index, previousArmour);
        setStateChangingWeapons();
        dispatch(PlayerEvent.Item_Equipped);
      }

      if (slot.isHelm){
        final previous = slots.helm;
        slots.helm = slot;
        slots.assignSlotAtIndex(index, previous);
        setStateChangingWeapons();
        dispatch(PlayerEvent.Item_Equipped);
      }

      if (slot == SlotType.Spell_Tome_Fireball) {
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

      if (slot == SlotType.Spell_Tome_Ice_Ring) {
        final cost = 5;
        if (magic < cost) return;
        magic -= cost;
        if (!slots.weapon.isStaff) {
          final index = slots.getSlotIndexWhere(isStaff);
          if (index == null) return;
          useSlot(index);
        }
        game.spawnFreezeRing(src: this);
        setStateChangingWeapons();
        return;
      }

      if (slot == SlotType.Spell_Tome_Split_Arrow) {
        final cost = 5;
        if (magic < cost) return;
        if (!slots.weapon.isBow){
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

      if (slot == SlotType.Potion_Red) {
        health = maxHealth;
        slots.assignSlotAtIndex(index, SlotType.Empty);
        setStateChangingWeapons();
        dispatch(PlayerEvent.Drink_Potion);
      }

      if (slot == SlotType.Potion_Blue) {
        magic = maxMagic;
        slots.assignSlotAtIndex(index, SlotType.Empty);
        setStateChangingWeapons();
        dispatch(PlayerEvent.Drink_Potion);
      }
  }

  void sellSlot(int index){
    if (index < 1) return;
    if (index > 6) return;
    final slotAtIndex = slots.getSlotTypeAtIndex(index);
    if (slotAtIndex.isEmpty) return;
    slots.assignSlotAtIndex(index, SlotType.Empty);
    dispatch(PlayerEvent.Item_Sold);
  }
}

class _PlayerSlots {
  SlotType weapon = SlotType.Empty;
  SlotType armour = SlotType.Empty;
  SlotType helm = SlotType.Empty;

  SlotType slot1 = SlotType.Empty;
  SlotType slot2 = SlotType.Empty;
  SlotType slot3 = SlotType.Empty;
  SlotType slot4 = SlotType.Empty;
  SlotType slot5 = SlotType.Empty;
  SlotType slot6 = SlotType.Empty;

  int? getSlotIndexWhere(bool Function(SlotType slotType) where){
     if(where(slot1)) return 1;
     if(where(slot2)) return 2;
     if(where(slot3)) return 3;
     if(where(slot4)) return 4;
     if(where(slot5)) return 5;
     if(where(slot6)) return 6;
     return null;
  }

  SlotType getSlotTypeAtIndex(int index){
      switch(index){
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

  void assignSlotAtIndex(int index, SlotType value){
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

  bool get emptySlotAvailable {
     if(slot1 == SlotType.Empty) return true;
     if(slot2 == SlotType.Empty) return true;
     if(slot3 == SlotType.Empty) return true;
     if(slot4 == SlotType.Empty) return true;
     if(slot5 == SlotType.Empty) return true;
     if(slot6 == SlotType.Empty) return true;
     return false;
  }

  void assignToEmpty(SlotType type){
    if(slot1 == SlotType.Empty) {
      slot1 = type;
      return;
    }
    if(slot2 == SlotType.Empty) {
      slot2 = type;
      return;
    }
    if(slot3 == SlotType.Empty) {
      slot3 = type;
      return;
    }
    if(slot4 == SlotType.Empty) {
      slot4 = type;
      return;
    }
    if(slot5 == SlotType.Empty) {
      slot5 = type;
      return;
    }
    if(slot6 == SlotType.Empty) {
      slot6 = type;
      return;
    }
    throw Exception("could not assign item, not empty slots");
  }
}

class _Orbs {
  int topaz = 0;
  int ruby = 0;
  int emerald = 0;
}

extension PlayerProperties on Player {

  bool get isHuman => type == CharacterType.Human;

  bool get unarmed {
    for(Weapon weapon in weapons){
      if (weapon.type == WeaponType.Unarmed) continue;
      return false;
    }
    return true;
  }

  Ability getAbilityByIndex(int index){
    switch(index){
      case 1:
        return ability1;
      case 2:
        return ability2;
      case 3:
        return ability3;
      case 4:
        return ability4;
      default:
        throw Exception("could not get ability at index $index");
    }
  }

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
