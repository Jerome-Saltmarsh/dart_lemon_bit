
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
      state.keyMap.interact: actions.sendRequestInteract,
      state.keyMap.perform: actions.performPrimaryAction,
      state.keyMap.speakLetsGo: actions.sayLetsGo,
      state.keyMap.speakLetsGreeting: actions.sayGreeting,
      state.keyMap.waitASecond: actions.sayWaitASecond,
      state.keyMap.text: actions.toggleMessageBox,
      state.keyMap.hourForwards: skipHour,
      state.keyMap.hourBackwards: reverseHour,
      state.keyMap.teleport: actions.teleportToMouse,
      state.keyMap.casteFireball: sendRequestCastFireball,
      key.digit1: (){
        if (game.player.isHuman){
          sendRequestEquip(1);
        }else{
          selectAbility1();
        }
      },
      key.digit2: (){
        if (game.player.isHuman){
          sendRequestEquip(2);
        }else{
          selectAbility2();
        }
      },
      state.keyMap.equip3: (){
        if (game.player.isHuman){
          sendRequestEquip(3);
        }else{
          selectAbility3();
        }
      },
      state.keyMap.equip4: (){
        if (game.player.isHuman){
          sendRequestEquip(4);
        }else{
          selectAbility4();
        }
      },
      state.keyMap.equip5: (){
        if (game.player.isHuman){
          // sendRequestEquip(index)
        }
      },
      state.keyMap.equip1B: selectAbility1,
      state.keyMap.equip2B: selectAbility2,
      state.keyMap.equip3B: (){
        if (game.player.isHuman){

        }else{
          selectAbility3();
        }
      },
      state.keyMap.equip4B: selectAbility4,
      key.arrowRight: sendRequest.hourIncrease,
      key.arrowLeft: sendRequest.hourDecrease,
    };    
  }
}