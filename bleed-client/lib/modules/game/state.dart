import 'package:bleed_client/Cache.dart';
import 'package:bleed_client/classes/Ability.dart';
import 'package:bleed_client/classes/Weapon.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/resources.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'classes.dart';
import 'enums.dart';


typedef BasicWidgetBuilder = Widget Function();

class GameState {
  final Watch<StoreTab> storeTab = Watch(storeTabs[0]);
  final _Player player = _Player();
  final _Soldier soldier = _Soldier();
  final Watch<GameStatus> status = Watch(GameStatus.Awaiting_Players);
  final TextEditingController textEditingControllerMessage = TextEditingController();
  final CharacterController characterController = CharacterController();
  final KeyMap keyMap = KeyMap();
  final Watch<bool> textMode = Watch(false);
  final Cache<bool> audioMuted = Cache(key: 'audio-muted', value: true);
  bool panningCamera = false;
  final FocusNode textFieldMessage = FocusNode();
  final Watch<SlotType> highLightSlotType = Watch(SlotType.Empty);

  final playerTextStyle = TextStyle(color: Colors.white);

  final List<String> letsGo = [
    "Come on!",
    "Let's go!",
    'Follow me!',
  ];

  final List<String> greetings = [
    'Hello',
    'Hi',
    'Greetings',
  ];

  final List<String> waitASecond = ['Wait a second', 'Just a moment'];

  final Map<SlotType, Widget> slotTypeImages = {
    SlotType.Sword_Short : resources.icons.sword,
    SlotType.Sword_Wooden : resources.icons.swords.wooden,
    SlotType.Sword_Long : resources.icons.swords.iron,
    SlotType.Bow_Wooden : resources.icons.bows.wooden,
    SlotType.Bow_Green : resources.icons.bows.green,
    SlotType.Bow_Gold : resources.icons.bows.gold,
    SlotType.Staff_Wooden : resources.icons.staffWooden,
    SlotType.Staff_Blue : resources.icons.staffBlue,
    SlotType.Staff_Golden : resources.icons.staffGolden,
    SlotType.Spell_Tome_Fireball : resources.icons.bookRed,
    SlotType.Armour_Standard : resources.icons.armourStandard,
  };
}

class _PlayerOrbs {
  final Watch<int> ruby = Watch(0);
  final Watch<int> topaz = Watch(0);
  final Watch<int> emerald = Watch(0);
}

class _PlayerSlots {
  final Watch<SlotType> weapon = Watch(SlotType.Empty);
  final Watch<SlotType> armour = Watch(SlotType.Empty);

  final Watch<SlotType> slot1 = Watch(SlotType.Empty);
  final Watch<SlotType> slot2 = Watch(SlotType.Empty);
  final Watch<SlotType> slot3 = Watch(SlotType.Empty);
  final Watch<SlotType> slot4 = Watch(SlotType.Empty);
  final Watch<SlotType> slot5 = Watch(SlotType.Empty);
  final Watch<SlotType> slot6 = Watch(SlotType.Empty);

  List<Watch<SlotType>> get list => [
    slot1,
    slot2,
    slot3,
    slot4,
    slot5,
    slot6,
  ];

  Watch<SlotType>? get emptySlot {
     if (slot1.value == SlotType.Empty){
       return slot1;
     }
     if (slot2.value == SlotType.Empty){
       return slot2;
     }
     if (slot3.value == SlotType.Empty){
       return slot3;
     }
     if (slot4.value == SlotType.Empty){
       return slot4;
     }
     if (slot5.value == SlotType.Empty){
       return slot5;
     }
     if (slot6.value == SlotType.Empty){
       return slot6;
     }
     return null;
  }
}

class _Soldier {
  final Watch<WeaponType> weaponType = Watch(WeaponType.Unarmed);
  final List<Weapon> weapons = [];
  final Watch<int> weaponRounds = Watch(0);
  final Watch<int> weaponCapacity = Watch(0);

  bool weaponUnlocked(WeaponType weaponType) {
    for (Weapon weapon in weapons) {
      if (weapon.type == weaponType) return true;
    }
    return false;
  }

  bool get shotgunUnlocked {
    for (Weapon weapon in weapons) {
      if (weapon.type == WeaponType.Shotgun) return true;
    }
    return false;
  }
}

class _Player {
  int id = -1;
  double x = -1;
  double y = -1;
  Vector2 abilityTarget = Vector2(0, 0);
  double abilityRange = 0;
  double abilityRadius = 0;
  double maxHealth = 0;
  Tile tile = Tile.Grass;
  double attackRange = 0;
  int team = 0;
  Vector2 attackTarget = Vector2(0, 0);
  final orbs = _PlayerOrbs();
  final slots = _PlayerSlots();
  final Watch<String> uuid = Watch("");
  final Watch<CharacterType> characterType = Watch(CharacterType.Human);
  final Watch<double> health = Watch(0.0);
  final Watch<int> experience = Watch(0);
  final Watch<int> level = Watch(1);
  final Watch<int> skillPoints = Watch(1);
  final Watch<int> nextLevelExperience = Watch(1);
  final Watch<double> experiencePercentage = Watch(0);
  final Watch<String> message = Watch("");
  final Watch<CharacterState> state = Watch(CharacterState.Idle);
  final Watch<bool> alive = Watch(true);
  final Watch<AbilityType> ability = Watch(AbilityType.None);
  final Watch<double> magic = Watch(0);
  final Watch<double> maxMagic = Watch(0);
  final Ability ability1 = Ability(1);
  final Ability ability2 = Ability(2);
  final Ability ability3 = Ability(3);
  final Ability ability4 = Ability(4);

  _Player() {
    magic.onChanged((double value) {
      ability1.canAfford.value = value >= ability1.magicCost.value;
      ability2.canAfford.value = value >= ability2.magicCost.value;
      ability3.canAfford.value = value >= ability3.magicCost.value;
      ability4.canAfford.value = value >= ability4.magicCost.value;
    });

    ability.onChanged((AbilityType abilityType) {
      ability1.selected.value = ability1.type.value == abilityType;
      ability2.selected.value = ability2.type.value == abilityType;
      ability3.selected.value = ability3.type.value == abilityType;
      ability4.selected.value = ability4.type.value == abilityType;
    });
  }

  // Properties
  bool get dead => !alive.value;
  bool get isHuman => characterType.value == CharacterType.Human;
}

