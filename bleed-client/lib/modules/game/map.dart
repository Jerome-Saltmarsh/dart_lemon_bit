
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
      state.keyMap.equip1: (){
        if (state.player.isHuman){
          // actions.playerEquip(1);
          actions.equipSlot(1);
        }else{
          actions.selectAbility1();
        }
      },
      state.keyMap.equip2: (){
        if (modules.game.state.player.isHuman){
          actions.equipSlot(2);
          // actions.playerEquip(2);
        }else{
          actions.selectAbility2();
        }
      },
      state.keyMap.equip3: (){
        if (modules.game.state.player.isHuman){
          // actions.playerEquip(3);
          actions.equipSlot(3);
        }else{
          actions.selectAbility3();
        }
      },
      state.keyMap.equip4: (){
        if (state.player.isHuman){
          // actions.playerEquip(4);
          actions.equipSlot(4);
        }else{
          actions.selectAbility4();
        }
      },
      state.keyMap.equip5: (){
        if (state.player.isHuman){
          actions.equipSlot(5);
        }
      },
      state.keyMap.equip6: (){
        if (state.player.isHuman){
          actions.equipSlot(6);
        }
      },
      state.keyMap.equip1B: actions.selectAbility1,
      state.keyMap.equip2B: actions.selectAbility2,
      state.keyMap.equip3B: (){
        if (state.player.isHuman){

        }else{
          actions.selectAbility3();
        }
      },
      state.keyMap.equip4B: actions.selectAbility4,
    };
  }
}

