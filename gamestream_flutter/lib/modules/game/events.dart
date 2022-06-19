import 'dart:async';
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/lower_tile_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';

import '../../isometric/grid.dart';
import 'state.dart';



class GameEvents {

  final GameActions actions;
  final GameState state;

  Timer? updateTimer;

  GameEvents(this.actions, this.state);

  void register(){
    engine.callbacks.onRightClicked = onMouseRightClick;
    gameType.onChanged(_onGameTypeChanged);
    player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    player.alive.onChanged(_onPlayerAliveChanged);
    player.state.onChanged(onPlayerCharacterStateChanged);
    messageBoxVisible.onChanged(onTextModeChanged);
    player.equippedWeapon.onChanged(onPlayerWeaponChanged);
    player.armour.onChanged(onPlayerArmourChanged);
    player.helm.onChanged(onPlayerHelmChanged);
    RawKeyboard.instance.addListener(onKeyboardEvent);
    sub(_onGameError);

    updateTimer = Timer.periodic(Duration(milliseconds: 1000.0 ~/ 30.0), (timer) {
      engine.updateEngine();
    });
  }

  void deregister(){
    RawKeyboard.instance.removeListener(onKeyboardEvent);
    updateTimer?.cancel();
  }

  void onKeyboardEvent(RawKeyEvent event){
     if (event is RawKeyDownEvent){
       if (event.physicalKey == PhysicalKeyboardKey.space){
         lowerTileMode = !lowerTileMode;
       }
        if (event.physicalKey == PhysicalKeyboardKey.arrowUp){
          if (keyPressed(LogicalKeyboardKey.shiftLeft)){
            edit.z++;
            if (edit.z >= gridTotalZ) {
              edit.z = gridTotalZ - 1;
            }
          } else {
            edit.row--;
            if (edit.row < 0){
              edit.row = 0;
            }
          }
        }
        if (event.physicalKey == PhysicalKeyboardKey.arrowRight){
          edit.column--;
          if (edit.column < 0){
            edit.column = 0;
          }
        }
        if (event.physicalKey == PhysicalKeyboardKey.arrowDown){
          if (keyPressed(LogicalKeyboardKey.shiftLeft)){
            edit.z--;
            if (edit.z < 0){
              edit.z = 0;
            }
          } else {
            edit.row = min(edit.row + 1, gridTotalRows - 1);
          }
        }
        if (event.physicalKey == PhysicalKeyboardKey.arrowLeft){
          edit.column++;
          if (edit.column >= gridTotalColumns){
            edit.column = gridTotalColumns - 1;
          }
        }
        edit.type.value = grid[edit.z][edit.row][edit.column];
        return;
     }
     if (event is RawKeyUpEvent){
       return;
     }
  }

  void onMouseRightClick(){
    sendRequestAttackSecondary();
  }

  void onPlayerWeaponChanged(int value){
    if (SlotType.isMetal(value)) {
      audio.drawSword(screenCenterWorldX, screenCenterWorldY);
    } else {
      audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onPlayerArmourChanged(int armour){
    audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
  }

  void onPlayerHelmChanged(int value){
    audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
  }

  void onTextModeChanged(bool textMode) {
    if (textMode) {
      state.textFieldMessage.requestFocus();
      return;
    }
    sendRequestSpeak(state.textEditingControllerMessage.text);
    state.textFieldMessage.unfocus();
    state.textEditingControllerMessage.text = "";
  }

  // TODO Remove
  void onPlayerCharacterStateChanged(int characterState){
    player.alive.value = characterState != CharacterState.Dead;
  }

  void _onPlayerAliveChanged(bool value) {
    print("events.onPlayerAliveChanged($value)");
    if (value) {
      // actions.cameraCenterPlayer();
      cameraCenterOnPlayer();
    }
  }

  Future _onGameError(GameError error) async {
    print("events.onGameEvent('$error')");
    switch (error) {
      case GameError.Insufficient_Resources:
        audio.error();
        break;
      case GameError.PlayerId_Required:
        core.actions.disconnect();
        website.actions.showDialogLogin();
        core.actions.setError("Account is null");
        return;
      case GameError.Subscription_Required:
        core.actions.disconnect();
        website.actions.showDialogSubscriptionRequired();
        return;
      case GameError.GameNotFound:
        core.actions.disconnect();
        core.actions.setError("game could not be found");
        return;
      case GameError.InvalidArguments:
        core.actions.disconnect();
        // if (event.length > 4) {
        //   String message = event.substring(4, event.length);
        //   core.actions.setError("Invalid Arguments: $message");
        //   return;
        // }
        core.actions.setError("game could not be found");
        return;
      case GameError.PlayerNotFound:
        core.actions.disconnect();
        core.actions.setError("Player could not be found");
        break;
      default:
        break;
    }
  }

  void _onPlayerCharacterTypeChanged(CharacterType characterType){
    print("events.onCharacterTypeChanged($characterType)");
    if (characterType == CharacterType.Human){
      engine.cursorType.value = CursorType.Precise;
    }else{
      engine.cursorType.value = CursorType.Basic;
    }
  }

  void _onGameTypeChanged(GameType? type) {
    print('events.onGameTypeChanged($type)');
    engine.camera.x = 0;
    engine.camera.y = 0;
    engine.zoom = 1;
  }

}