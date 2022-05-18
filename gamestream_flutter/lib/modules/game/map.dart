
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/audio.dart';

import 'actions.dart';
import 'state.dart';

class GameMap {

  final GameState state;
  final GameActions actions;
  late final Map<LogicalKeyboardKey, Function> keyPressedHandlers;

  GameMap(this.state, this.actions){
    keyPressedHandlers = {
      state.keyMap.perform: (){
        if (state.textBoxVisible.value) return;
        actions.playerPerform();
      },
      state.keyMap.speak: actions.toggleMessageBox,
      state.keyMap.toggleAudio: audio.toggleSoundEnabled,
      state.keyMap.hourForwards: actions.skipHour,
      state.keyMap.hourBackwards: actions.reverseHour,
      state.keyMap.toggleObjectsDestroyable: actions.toggleObjectsDestroyable,
      state.keyMap.teleport: actions.teleportToMouse,
      state.keyMap.spawnZombie: actions.spawnZombie,
      state.keyMap.respawn: actions.respawn,
      state.keyMap.equip1: actions.equipSlot1,
      state.keyMap.equip2: actions.equipSlot2,
      state.keyMap.equip3: actions.equipSlot3,
      state.keyMap.equip4: actions.equipSlot4,
      state.keyMap.equip5: actions.equipSlot5,
      state.keyMap.equip6: actions.equipSlot6,
      state.keyMap.debug: actions.toggleDebugMode,
    };
  }
}

