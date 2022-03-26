import 'package:gamestream_flutter/classes/Weapon.dart';
import 'package:bleed_common/AbilityType.dart';
import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/OrbType.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/WeaponType.dart';
import 'package:gamestream_flutter/resources.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/advanced_watch.dart';
import 'package:lemon_watch/watch.dart';

import 'classes.dart';
import 'enums.dart';


typedef BasicWidgetBuilder = Widget Function();

class GameState {
  final player = _Player();
  final textEditingControllerMessage = TextEditingController();
  final characterController = CharacterController();
  final keyMap = KeyMap();
  final textFieldMessage = FocusNode();
  final debugPanelVisible = Watch(false);
  final compilePaths = Watch(false);
  final storeTab = Watch(storeTabs[0]);
  final textBoxVisible = Watch(false);
  final highLightSlotType = Watch(SlotType.Empty);
  final highlightSlot = Watch<Slot?>(null);

  final highlightPanelPosition = Vector2(0, 0);
  final frameSmoothing = Watch(true);
  final playerTextStyle = TextStyle(color: Colors.white);
  var panningCamera = false;
  var framesSinceOrbAcquired = 999;
  var lastOrbAcquired = OrbType.Emerald;
  var smoothed = 3;

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
    SlotType.Empty: resources.icons.empty,
    SlotType.Sword_Short : resources.icons.sword,
    SlotType.Sword_Wooden : resources.icons.swords.wooden,
    SlotType.Golden_Necklace : resources.icons.trinkets.goldenNecklace,
    SlotType.Sword_Long : resources.icons.swords.iron,
    SlotType.Bow_Wooden : resources.icons.bows.wooden,
    SlotType.Bow_Green : resources.icons.bows.green,
    SlotType.Bow_Gold : resources.icons.bows.gold,
    SlotType.Staff_Wooden : resources.icons.staffs.wooden,
    SlotType.Staff_Blue : resources.icons.staffs.blue,
    SlotType.Staff_Golden : resources.icons.staffs.golden,
    SlotType.Spell_Tome_Fireball : resources.icons.books.red,
    SlotType.Spell_Tome_Ice_Ring : resources.icons.books.blue,
    SlotType.Spell_Tome_Split_Arrow : resources.icons.books.blue,
    SlotType.Body_Blue : resources.icons.armour.standard,
    SlotType.Steel_Helmet : resources.icons.heads.steel,
    SlotType.Magic_Hat : resources.icons.heads.magic,
    SlotType.Rogue_Hood : resources.icons.heads.rogue,
    SlotType.Potion_Red : resources.icons.potions.red,
    SlotType.Potion_Blue : resources.icons.potions.blue,
    SlotType.Armour_Padded : resources.icons.armour.padded,
    SlotType.Magic_Robes : resources.icons.armour.magic,
    SlotType.Handgun : resources.icons.firearms.handgun,
    SlotType.Shotgun : resources.icons.firearms.shotgun,
  };
}

class _PlayerOrbs {
  final AdvancedWatch<int> ruby = AdvancedWatch(0);
  final AdvancedWatch<int> topaz = AdvancedWatch(0);
  final AdvancedWatch<int> emerald = AdvancedWatch(0);
}

class Slot {
  final type = Watch(SlotType.Empty);
  final amount = Watch(0);
}

class Slots {
  final weapon = Slot();
  final armour = Watch(SlotType.Empty);
  final helm = Watch(SlotType.Empty);

  final slot1 = Slot();
  final slot2 = Slot();
  final slot3 = Slot();
  final slot4 = Slot();
  final slot5 = Slot();
  final slot6 = Slot();
}

class _Player {
  // late List<int> byteId;
  double x = 0;
  double y = 0;
  int id = -1;
  int team = 0;
  Vector2 abilityTarget = Vector2(0, 0);
  double abilityRange = 0;
  double abilityRadius = 0;
  double maxHealth = 0;
  Tile tile = Tile.Grass;
  double attackRange = 0;
  final Vector2 attackTarget = Vector2(0, 0);
  final orbs = _PlayerOrbs();
  final slots = Slots();
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

  // Properties
  bool get dead => !alive.value;
  bool get isHuman => characterType.value == CharacterType.Human;
}

