
import 'package:bleed_client/modules/modules.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'state.dart';

class GameMap {

  final GameState state;
  final GameActions actions;
  late final Map<LogicalKeyboardKey, Function> keyPressedHandlers;

  GameMap(this.state, this.actions){
    keyPressedHandlers = {
      state.keyMap.runUp: actions.playerInteract,
      state.keyMap.interact: actions.playerInteract,
      state.keyMap.perform: actions.playerPerform,
      state.keyMap.speakLetsGo: actions.sayLetsGo,
      state.keyMap.speakLetsGreeting: actions.sayGreeting,
      state.keyMap.waitASecond: actions.sayWaitASecond,
      state.keyMap.text: actions.toggleMessageBox,
      state.keyMap.toggleAudio: actions.toggleAudio,
      state.keyMap.hourForwards: actions.skipHour,
      state.keyMap.hourBackwards: actions.reverseHour,
      state.keyMap.teleport: actions.teleportToMouse,
      state.keyMap.spawnZombie: actions.spawnZombie,
      state.keyMap.respawn: actions.respawn,
      state.keyMap.equip1: actions.equipSlot1,
      state.keyMap.equip2: actions.equipSlot2,
      state.keyMap.equip3: actions.equipSlot3,
      state.keyMap.equip4: actions.equipSlot4,
      state.keyMap.equip5: actions.equipSlot5,
      state.keyMap.equip6: actions.equipSlot6,
    };
  }
}

