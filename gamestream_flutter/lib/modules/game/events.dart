import 'dart:async';

import 'package:bleed_common/AbilityType.dart';
import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/GameError.dart';
import 'package:bleed_common/GameEventType.dart';
import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/OrbType.dart';
import 'package:bleed_common/PlayerEvent.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/parse.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/opposite.dart';
import 'package:lemon_math/randomBool.dart';
import 'package:lemon_math/randomInt.dart';

import 'state.dart';


final _spawn = isometric.spawn;

class GameEvents {

  final GameActions actions;
  final GameState state;

  Timer? updateTimer;

  GameEvents(this.actions, this.state);

  void register(){
    print("modules.game.events.register()");
    engine.callbacks.onLeftClicked = actions.playerPerform;
    engine.callbacks.onPanStarted = actions.playerPerform;
    engine.callbacks.onLongLeftClicked = actions.playerRun;
    engine.callbacks.onRightClicked = onMouseRightClick;
    game.type.onChanged(_onGameTypeChanged);
    state.player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    state.player.alive.onChanged(_onPlayerAliveChanged);
    state.player.state.onChanged(onPlayerCharacterStateChanged);
    state.textBoxVisible.onChanged(onTextModeChanged);
    state.player.orbs.emerald.listen(onEmeraldsChanged);
    state.player.orbs.ruby.listen(onEmeraldsChanged);
    state.player.orbs.topaz.listen(onEmeraldsChanged);
    state.player.slots.weapon.type.onChanged(onPlayerWeaponChanged);
    state.player.slots.armour.type.onChanged(onPlayerArmourChanged);
    state.player.slots.helm.type.onChanged(onPlayerHelmChanged);
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

  bool _pressed = false;


  void onKeyboardEvent(RawKeyEvent event){
     if (event is RawKeyDownEvent){
        if (event.physicalKey == PhysicalKeyboardKey.keyT){
          if (_pressed) return;
          _pressed = true;
          sendRequestConstruct();
        }
        return;
     }
     if (event is RawKeyUpEvent){
       if (event.physicalKey == PhysicalKeyboardKey.keyT){
         _pressed = false;
       }
       return;
     }
  }

  void onMouseRightClick(){
    if (state.player.ability.value != AbilityType.None) {
      actions.deselectAbility();
      return;
    }
    sendRequestAttack();
  }

  void onPlayerWeaponChanged(int value){
    if (SlotType.isMetal(value)) {
      audio.drawSword(screenCenterWorldX, screenCenterWorldY);
    } else {
      audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onPlayerEvent(int event){
    switch (event) {
      case PlayerEvent.Level_Up:
        modules.game.actions.emitPixelExplosion(modules.game.state.player.x, modules.game.state.player.y, amount: 10);
        audio.buff(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Skill_Upgraded:
        audio.unlock(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Dash_Activated:
        audio.buff11(modules.game.state.player.x, modules.game.state.player.y);
        break;
      case PlayerEvent.Item_Purchased:
        audio.itemPurchased(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Ammo_Acquired:
        audio.itemAcquired(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Item_Equipped:
        audio.itemAcquired(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Medkit:
        audio.medkit(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Item_Sold:
        audio.coins(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Drink_Potion:
        audio.bottle(screenCenterWorldX, screenCenterWorldY);
        break;
    }
  }

  void onPlayerArmourChanged(int armour){
    audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
  }

  void onPlayerHelmChanged(int value){
    audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
  }

  void onEmeraldsChanged(int current, int previous){
    // print('onEmeraldsChanged(current: $current, previous: $previous)');
    if (current > previous) {
      state.framesSinceOrbAcquired = 0;
      state.lastOrbAcquired = OrbType.Emerald;
      audio.coins24(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onRubiesChanged(int current, int previous){
    // print('onRubiesChanged(current: $current)');
    if (current > previous) {
      state.framesSinceOrbAcquired = 0;
      state.lastOrbAcquired = OrbType.Ruby;
      audio.coins24(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onTopazChanged(int current, int previous){
    // print('onTopazChanged(current: $current)');
    if (current > previous) {
      state.framesSinceOrbAcquired = 0;
      state.lastOrbAcquired = OrbType.Topaz;
      audio.coins24(screenCenterWorldX, screenCenterWorldY);
    }
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
    modules.game.state.player.alive.value = characterState != CharacterState.Dead;
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
        if (event.length > 4) {
          String message = event.substring(4, event.length);
          core.actions.setError("Invalid Arguments: $message");
          return;
        }
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

  void _onGameTypeChanged(GameType type) {
    print('events.onGameTypeChanged($type)');
    core.actions.clearSession();
    engine.camera.x = 0;
    engine.camera.y = 0;
    engine.zoom = 1;
  }

  void onGameEvent(int type, double x, double y, double angle) {
    switch (type) {
      case GameEventType.Handgun_Fired:
        audio.handgunShot(x, y);
        const distance = 12.0;
        final xForward = adjacent(angle, distance);
        final yForward = opposite(angle, distance);
        _spawn.shell(x: x + xForward, y: y + yForward);
        break;
      case GameEventType.Shotgun_Fired:
        audio.shotgunShot(x, y);
        _spawn.shell(x: x, y: y);
        break;
      case GameEventType.SniperRifle_Fired:
        audio.sniperShot(x, y);
        _spawn.shell(x: x, y: y);
        break;
      case GameEventType.MachineGun_Fired:
        audio.assaultRifleShot(x, y);
        isometric.spawn.shell(x: x, y: y);
        break;
      case GameEventType.Character_Struck:
        audio.bloodyImpact(x, y);
        final total = randomInt(5, 10);
        for (var i = 0; i < total; i++) {
          _spawn.blood(
            x: x,
            y: y,
            z: 0.3,
            angle: angle + giveOrTake(0.2),
            speed: 4.0 + giveOrTake(2),
            zv: 0.07 + giveOrTake(0.01),
          );
        }
        break;
      case GameEventType.Player_Hit:
        if (randomBool()) {
          audio.humanHurt(x, y);
        }
        break;
      case GameEventType.Zombie_Killed:
        _spawn.headZombie(x: x, y: y, z: 0.5, angle: angle, speed: 4.0);
        _spawn.arm(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        _spawn.arm(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        _spawn.legZombie(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        _spawn.legZombie(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        _spawn.organ(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5), zv: 0.1);
        audio.zombieDeath(x, y);

        // final total = randomInt(5, 10);
        // for (var i = 0; i < total; i++) {
        //   _spawn.blood(
        //     x: x,
        //     y: y,
        //     z: 0.3,
        //     angle: angle + giveOrTake(0.2),
        //     speed: 4.0 + giveOrTake(2),
        //     zv: 0.07 + giveOrTake(0.01),
        //   );
        // }
        break;

      case GameEventType.Zombie_Target_Acquired:
        audio.zombieTargetAcquired(x, y);
        break;
      case GameEventType.Bullet_Hole:
        actions.spawnBulletHole(x.toDouble(), y.toDouble());
        break;
      case GameEventType.Zombie_Strike:
        audio.zombieBite(x, y);
        // double r = 1;
        // double s = 0.15;
        // for (int i = 0; i < randomInt(2, 4); i++) {
        //   isometric.spawn.blood(x, y, 0.3,
        //       xv: xv * s + giveOrTake(r),
        //       yv: yv * s + giveOrTake(r),
        //       zv: randomBetween(0, 0.07));
        // }
        break;
      case GameEventType.Player_Death:
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.Explosion:
        _spawn.explosion(x, y);
        break;
      case GameEventType.FreezeCircle:
        _spawn.freezeCircle(x: x, y: y,);
        break;
      case GameEventType.Teleported:
        actions.emitPixelExplosion(x, y);
        audio.magicalSwoosh(x, y);
        break;
      case GameEventType.Blue_Orb_Fired:
        audio.sciFiBlaster1(x, y);
        break;
      case GameEventType.Arrow_Hit:
        audio.arrowImpact(x, y);
        break;
      case GameEventType.Draw_Bow:
        audio.drawBow(x, y);
        break;
      case GameEventType.Release_Bow:
        audio.releaseBow(x, y);
        break;
      case GameEventType.Sword_Woosh:
        audio.swordWoosh(x, y);
        break;
      case GameEventType.Objective_Reached:
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.EnemyTargeted:
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.Arrow_Fired:
        audio.arrowFlyingPast6(x, y);
        break;
      case GameEventType.Clip_Empty:
        audio.dryShot2(x, y);
        return;
      case GameEventType.Reloaded:
        audio.magIn2(x, y);
        return;
      case GameEventType.Use_MedKit:
        audio.medkit(x, y);
        break;
      case GameEventType.Throw_Grenade:
        audio.playAudioThrowGrenade(x, y);
        break;
      case GameEventType.Item_Acquired:
        audio.itemAcquired(x, y);
        break;
      case GameEventType.Knife_Strike:
        audio.playAudioKnifeStrike(x, y);
        break;
      case GameEventType.Health_Acquired:
        audio.playAudioHeal(x, y);
        break;
      case GameEventType.Crate_Breaking:
        audio.playAudioCrateBreaking(x, y);
        break;
      case GameEventType.Ammo_Acquired:
        audio.gunPickup(x, y);
        break;
      case GameEventType.Credits_Acquired:
        audio.playAudioCollectStar(x, y);
        break;
      case GameEventType.Pot_Destroyed:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.potShard(x, y);
        }
        audio.potBreaking(x, y);
        break;
      case GameEventType.Object_Struck:
        audio.objectStruck(x, y);
        break;
      case GameEventType.Rock_Destroyed:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.rockShard(x, y);
        }
        audio.rockBreaking(x, y);
        break;

      case GameEventType.Rock_Struck:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.rockShard(x, y);
        }
        audio.objectStruck(x, y);
        break;
      case GameEventType.Tree_Struck:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.treeShard(x, y);
        }
        audio.objectStruck(x, y);
        break;

      case GameEventType.Tree_Destroyed:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.treeShard(x, y);
        }
        audio.treeBreaking(x, y);
        break;
    }
  }
}