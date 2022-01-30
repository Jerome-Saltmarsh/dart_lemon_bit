
import 'package:bleed_client/input.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'state.dart';

class GameMap {
  
  final GameState state;
  final GameActions actions;
  late final Map<LogicalKeyboardKey, Function> keyPressedHandlers;

  GameMap(this.state, this.actions){
    keyPressedHandlers = {
      state.keyMap.interact: actions.playerInteract,
      state.keyMap.perform: actions.playerPerform,
      state.keyMap.speakLetsGo: actions.sayLetsGo,
      state.keyMap.speakLetsGreeting: actions.sayGreeting,
      state.keyMap.waitASecond: actions.sayWaitASecond,
      state.keyMap.text: actions.toggleMessageBox,
      state.keyMap.hourForwards: actions.skipHour,
      state.keyMap.hourBackwards: actions.reverseHour,
      state.keyMap.teleport: actions.teleportToMouse,
      state.keyMap.casteFireball: actions.sendRequestCastFireball,
      state.keyMap.equip1: (){
        if (game.player.isHuman){
          actions.playerEquip(1);
        }else{
          actions.selectAbility1();
        }
      },
      state.keyMap.equip2: (){
        if (game.player.isHuman){
          actions.playerEquip(2);
        }else{
          actions.selectAbility2();
        }
      },
      state.keyMap.equip3: (){
        if (game.player.isHuman){
          actions.playerEquip(3);
        }else{
          actions.selectAbility3();
        }
      },
      state.keyMap.equip4: (){
        if (game.player.isHuman){
          actions.playerEquip(4);
        }else{
          actions.selectAbility4();
        }
      },
      state.keyMap.equip5: (){
        if (game.player.isHuman){
          // sendRequestEquip(index)
        }
      },
      state.keyMap.equip1B: actions.selectAbility1,
      state.keyMap.equip2B: actions.selectAbility2,
      state.keyMap.equip3B: (){
        if (game.player.isHuman){

        }else{
          actions.selectAbility3();
        }
      },
      state.keyMap.equip4B: actions.selectAbility4,
    };
  }
}