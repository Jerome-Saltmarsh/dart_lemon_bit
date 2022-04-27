import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/advanced_watch.dart';
import 'package:lemon_watch/watch.dart';

import 'classes.dart';
import 'enums.dart';

class GameState {
  final player = Player();
  final textEditingControllerMessage = TextEditingController();
  final characterController = CharacterController();
  final keyMap = KeyMap();
  final textFieldMessage = FocusNode();
  final debugPanelVisible = Watch(false);
  final compilePaths = Watch(false);
  final storeTab = Watch(storeTabs[0]);
  final textBoxVisible = Watch(false);
  final highlightSlotType = Watch(SlotType.Empty);
  final highlightStructureType = Watch<int?>(null);
  final highlightSlot = Watch<Slot?>(null);

  final cameraMode = Watch(CameraMode.Chase);
  final framesSmoothed = Watch(0);

  final playerTextStyle = TextStyle(color: Colors.white);
  var panningCamera = false;
  var framesSinceOrbAcquired = 999;
  var lastOrbAcquired = OrbType.Emerald;

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
  final armour = Slot();
  final helm = Slot();

  final slot1 = Slot();
  final slot2 = Slot();
  final slot3 = Slot();
  final slot4 = Slot();
  final slot5 = Slot();
  final slot6 = Slot();
}

class Player {
  var score = 0;
  var x = 0.0;
  var y = 0.0;
  var id = -1;
  var team = 0;
  var abilityRange = 0.0;
  var abilityRadius = 0.0;
  var maxHealth = 0.0;
  var tile = Tile.Grass;
  var attackRange = 0.0;
  final abilityTarget = Vector2(0, 0);
  final storeVisible = Watch(false);
  final attackTarget = Vector2(0, 0);
  final orbs = _PlayerOrbs();
  // final slots = Slots();
  final equipped = Watch(TechType.Unarmed);
  final armour = Watch(TechType.Unarmed);
  final helm = Watch(TechType.Unarmed);

  final characterType = Watch(CharacterType.Human);
  final health = Watch(0.0);
  final experience = Watch(0);
  final level = Watch(1);
  final skillPoints = Watch(1);
  final nextLevelExperience = Watch(1);
  final experiencePercentage = Watch(0.0);
  final message = Watch("");
  final state = Watch(CharacterState.Idle);
  final alive = Watch(true);
  final ability = Watch(AbilityType.None);
  final magic = Watch(0.0);
  final maxMagic = Watch(0.0);
  final wood = Watch(0);
  final stone = Watch(0);
  final gold = Watch(0);

  // Properties
  bool get dead => !alive.value;
  bool get isHuman => characterType.value == CharacterType.Human;
}

