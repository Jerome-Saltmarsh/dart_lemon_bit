import 'dart:async';
import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/audio.dart';
import 'package:gamestream_flutter/classes/Explosion.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/isometric/state/edit_state.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/state/grid.dart';
import 'package:gamestream_flutter/isometric/state/lower_tile_mode.dart';
import 'package:gamestream_flutter/isometric/state/player.dart';
import 'package:gamestream_flutter/modules/game/actions.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/parse.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/library.dart';

import 'state.dart';

final _spawn = isometric.spawn;

class GameEvents {

  final GameActions actions;
  final GameState state;

  Timer? updateTimer;

  GameEvents(this.actions, this.state);

  void register(){
    engine.callbacks.onLeftClicked = actions.playerPerform;
    engine.callbacks.onPanStarted = actions.playerPerform;
    engine.callbacks.onLongLeftClicked = actions.playerRun;
    engine.callbacks.onRightClicked = onMouseRightClick;
    gameType.onChanged(_onGameTypeChanged);
    player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    player.alive.onChanged(_onPlayerAliveChanged);
    player.state.onChanged(onPlayerCharacterStateChanged);
    state.textBoxVisible.onChanged(onTextModeChanged);
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


  void onMouseLeftClick() {
    actions.setCharacterActionPerform();
  }


  void onMouseRightClick(){
    sendRequestAttackSecondary();
    // if (modules.game.structureType.isNotNull) {
    //   modules.game.structureType.value = null;
    //   return;
    // }
    //
    // if (state.player.ability.value != AbilityType.None) {
    //   actions.deselectAbility();
    //   return;
    // }
    // sendRequestAttack();
  }

  void onPlayerWeaponChanged(int value){
    if (SlotType.isMetal(value)) {
      audio.drawSword(screenCenterWorldX, screenCenterWorldY);
    } else {
      audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onPlayerEvent(int event) {
    switch (event) {
      case PlayerEvent.Level_Up:
        modules.game.actions.emitPixelExplosion(player.x, player.y, amount: 20);
        audio.buff(player.x, player.y);
        isometric.spawnFloatingText(player.x, player.y, 'LEVEL UP');
        break;
      case PlayerEvent.Skill_Upgraded:
        audio.unlock(player.x, player.y);
        break;
      case PlayerEvent.Dash_Activated:
        audio.buff11(player.x, player.y);
        break;
      case PlayerEvent.Item_Purchased:
        audio.winSound2();
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
      case PlayerEvent.Collect_Wood:
        audio.coins(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Collect_Rock:
        audio.coins(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Collect_Experience:
        audio.collectStar3(screenCenterWorldX, screenCenterWorldY);
        break;
      case PlayerEvent.Collect_Gold:
        audio.coins(screenCenterWorldX, screenCenterWorldY);
        break;
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

  void _onGameTypeChanged(GameType? type) {
    print('events.onGameTypeChanged($type)');
    engine.camera.x = 0;
    engine.camera.y = 0;
    engine.zoom = 1;
  }

  void onGameEvent(int type, double x, double y, double angle) {
    switch (type) {
      case GameEventType.Handgun_Fired:
        audio.handgunShot(x, y);
        const distance = 12.0;
        final xForward = getAdjacent(angle, distance);
        final yForward = getOpposite(angle, distance);
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
        break;

      case GameEventType.Zombie_Target_Acquired:
        audio.zombieTargetAcquired(x, y);
        break;
      case GameEventType.Bullet_Hole:
        actions.spawnBulletHole(x.toDouble(), y.toDouble());
        break;
      case GameEventType.Zombie_Strike:
        audio.zombieBite(x, y);
        break;
      case GameEventType.Player_Death:
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.Explosion:
        _spawn.spawnExplosion(x, y);
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
        audio.crateBreaking(x, y);
        break;
      case GameEventType.Ammo_Acquired:
        audio.gunPickup(x, y);
        break;
      case GameEventType.Credits_Acquired:
        audio.collectStar4(x, y);
        break;

      case GameEventType.Object_Destroyed_Pot:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.potShard(x, y);
        }
        audio.potBreaking(x, y);
        break;


      case GameEventType.Object_Destroyed_Rock:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.rockShard(x, y);
        }
        audio.rockBreaking(x, y);
        break;

      case GameEventType.Object_Destroyed_Tree:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.treeShard(x, y);
        }
        audio.treeBreaking(x, y);
        break;

      case GameEventType.Object_Destroyed_Chest:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.shardWood(x, y);
        }
        audio.crateDestroyed(x, y);
        break;

      case GameEventType.Material_Struck_Wood:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.treeShard(x, y);
        }
        audio.materialStruckWood(x, y);
        break;

      case GameEventType.Material_Struck_Rock:
        for (var i = 0; i < 8; i++) {
          isometric.spawn.rockShard(x, y);
        }
        audio.materialStruckRock(x, y);
        break;

      case GameEventType.Material_Struck_Flesh:
        audio.materialStruckFlesh(x, y);
        final total = randomInt(2, 5);
        for (var i = 0; i < total; i++) {
          _spawn.spawnParticleBlood(
            x: x,
            y: y,
            z: 0.3,
            angle: angle + giveOrTake(0.2),
            speed: 4.0 + giveOrTake(2),
            zv: 0.07 + giveOrTake(0.01),
          );
        }
        for (var i = 0; i < 1; i++) {
          _spawn.spawnParticleBlood(
            x: x,
            y: y,
            z: 0.3,
            angle: angle + giveOrTake(0.2) + pi,
            speed: 1.0 + giveOrTake(1),
            zv: 0.07 + giveOrTake(0.01),
          );
        }

        break;

      case GameEventType.Material_Struck_Metal:
        audio.materialStruckMetal(x, y);
        break;

      case GameEventType.Zombie_Hurt:
        audio.zombieHurt(x, y);
        break;

      case GameEventType.Blue_Orb_Deactivated:
        for (var i = 0; i < 8; i++){
          spawnParticleOrbShard(
              x: x,
              y: y,
              duration: 30,
              speed: randomBetween(1, 2)
          );
        }
        isometric.spawn.spawnEffect(x: x, y: y, type: EffectType.Explosion, duration: 30);
        break;

      case GameEventType.Projectile_Fired_Fireball:
        audio.firebolt(x, y);
        break;

    }
  }
}