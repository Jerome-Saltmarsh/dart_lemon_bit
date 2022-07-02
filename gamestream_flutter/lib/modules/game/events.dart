import 'dart:async';
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/lower_tile_mode.dart';
import 'package:gamestream_flutter/isometric/message_box.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
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
    gameType.onChanged(_onGameTypeChanged);
    player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    player.alive.onChanged(_onPlayerAliveChanged);
    player.state.onChanged(onPlayerCharacterStateChanged);
    messageBoxVisible.onChanged(onTextModeChanged);
    player.weaponType.onChanged(onPlayerWeaponChanged);
    player.armourType.onChanged(onPlayerArmourChanged);
    player.headType.onChanged(onPlayerHelmChanged);
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
            edit.z.value++;
            if (edit.z.value >= gridTotalZ) {
              edit.z.value = gridTotalZ - 1;
            }
          } else {
            edit.row.value--;
            if (edit.row.value < 0){
              edit.row.value = 0;
            }
          }
        }
        if (event.physicalKey == PhysicalKeyboardKey.arrowRight){
          edit.column.value--;
          if (edit.column.value < 0){
            edit.column.value = 0;
          }
        }
        if (event.physicalKey == PhysicalKeyboardKey.arrowDown){
          if (keyPressed(LogicalKeyboardKey.shiftLeft)){
            edit.z.value--;
            if (edit.z.value < 0){
              edit.z.value = 0;
            }
          } else {
            edit.row.value = min(edit.row.value + 1, gridTotalRows - 1);
          }
        }
        if (event.physicalKey == PhysicalKeyboardKey.arrowLeft){
          edit.column.value++;
          if (edit.column.value >= gridTotalColumns){
            edit.column.value = gridTotalColumns - 1;
          }
        }
        edit.type.value = grid[edit.z.value][edit.row.value][edit.column.value];
        return;
     }
     if (event is RawKeyUpEvent){
       return;
     }
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