import 'package:bleed_client/audio.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/GameEventType.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/SlotType.dart';
import 'package:bleed_client/modules/game/actions.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/opposite.dart';
import 'package:lemon_math/randomBool.dart';
import 'package:lemon_math/randomInt.dart';

import 'state.dart';


class GameEvents {

  final GameActions actions;
  final GameState state;

  GameEvents(this.actions, this.state);

  void register(){
    print("modules.game.events.register()");
    engine.callbacks.onLeftClicked = actions.playerPerform;
    engine.callbacks.onPanStarted = actions.playerPerform;
    engine.callbacks.onLongLeftClicked = actions.playerPerform;
    engine.callbacks.onRightClicked = actions.deselectAbility;
    state.player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    game.type.onChanged(_onGameTypeChanged);
    state.player.uuid.onChanged(_onPlayerUuidChanged);
    state.player.alive.onChanged(_onPlayerAliveChanged);
    state.player.state.onChanged(onPlayerCharacterStateChanged);
    state.status.onChanged(_onGameStatusChanged);
    state.textMode.onChanged(onTextModeChanged);

    state.player.orbs.emerald.listen(onEmeraldsChanged);
    state.player.orbs.ruby.listen(onEmeraldsChanged);
    state.player.orbs.topaz.listen(onEmeraldsChanged);
    state.player.slots.weapon.onChanged(onPlayerWeaponChanged);
    state.player.slots.armour.onChanged(onPlayerArmourChanged);
    state.player.slots.helm.onChanged(onPlayerHelmChanged);
    sub(_onGameError);
  }

  void onPlayerWeaponChanged(SlotType value){
    print("game.events.onPlayerArmourChanged($value)");
    if (value.isSword && value.isMetal) {
      audio.drawSword(screenCenterWorldX, screenCenterWorldY);
    } else {
      audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onPlayerArmourChanged(SlotType armour){
    print("game.events.onPlayerArmourChanged($armour)");
    audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
  }

  void onPlayerHelmChanged(SlotType value){
    print("game.events.onPlayerHelmChanged($value)");
    audio.changeCloths(screenCenterWorldX, screenCenterWorldY);
  }

  void onEmeraldsChanged(int current, int previous){
    print('onEmeraldsChanged(current: $current, previous: $previous)');
    if (current > previous) {
       audio.coins(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onRubiesChanged(int current, int previous){
    print('onRubiesChanged(current: $current)');
    if (current > previous) {
      audio.coins(screenCenterWorldX, screenCenterWorldY);
    }
  }

  void onTopazChanged(int current, int previous){
    print('onTopazChanged(current: $current)');
    if (current > previous) {
      audio.coins(screenCenterWorldX, screenCenterWorldY);
    }
  }


  void onTextModeChanged(bool textMode){
    if (textMode){
      state.textFieldMessage.requestFocus();
    }else{
      state.textFieldMessage.unfocus();
      state.textEditingControllerMessage.text = "";
    }
  }

  void onPlayerCharacterStateChanged(CharacterState characterState){
    modules.game.state.player.alive.value = characterState != CharacterState.Dead;
  }

  void _onPlayerAliveChanged(bool value) {
    print("events.onPlayerAliveChanged($value)");
    if (value) {
      actions.cameraCenterPlayer();
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

  void _onPlayerUuidChanged(String uuid) {
    print("events.onPlayerUuidChanged($uuid)");
    if (uuid.isNotEmpty) {
      actions.cameraCenterPlayer();
    }
  }

  void _onGameStatusChanged(GameStatus value){
    print('events.onGameStatusChanged($value)');
    switch(value){
      case GameStatus.In_Progress:
        engine.fullScreenEnter();
        break;
      default:
        engine.fullScreenExit();
        break;
    }
  }

  void onGameEvent(GameEventType type, double x, double y, double angle) {
    switch (type) {
      case GameEventType.Handgun_Fired:
        audio.playAudioHandgunShot(x, y);
        isometric.spawn.shell(x: x, y: y, z: 0.2, zv: 0.1, angle: angle, speed: 0.1);
        break;
      case GameEventType.Shotgun_Fired:
        audio.shotgunShot(x, y);
        isometric.spawn.shell(x: x, y: y, z: 0.2, zv: 0.1, angle: angle, speed: 0.1);
        // isometric.spawn.shotSmoke(x, y, xv, yv);
        break;
      case GameEventType.SniperRifle_Fired:
        audio.sniperShot(x, y);
        isometric.spawn.shell(x: x, y: y, z: 0.2, zv: 0.1, angle: angle, speed: 0.1);
        break;
      case GameEventType.MachineGun_Fired:
        audio.assaultRifleShot(x, y);
        isometric.spawn.shell(x: x, y: y, z: 0.2, zv: 0.1, angle: angle, speed: 0.1);
        break;
      case GameEventType.Character_Struck:
        audio.bloodyImpact(x, y);
        final speed = 4.0;
        final speedVariation = 2;
        final total = randomInt(5, 10);
        for (int i = 0; i < total; i++) {
          isometric.spawn.blood(
            x: x,
            y: y,
            z: 0.3,
            angle: angle + giveOrTake(0.2),
            speed: speed + giveOrTake(speedVariation),
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
        isometric.spawn.headZombie(x: x, y: y, z: 0.5, angle: angle, speed: 4.0);
        isometric.spawn.arm(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        isometric.spawn.arm(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        isometric.spawn.legZombie(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        isometric.spawn.legZombie(x: x, y: y, z: 0.5, angle: angle + giveOrTake(0.5), speed: 4.0 + giveOrTake(0.5));
        // isometric.spawn.legZombie(x, y, 0.2,
        //     xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
        // isometric.spawn.organ(x, y, 0.3,
        //     xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
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
      // playAudioPlayerDeath(x, y);
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.Explosion:
        isometric.spawn.explosion(x, y);
        break;
      case GameEventType.FreezeCircle:
        isometric.spawn.freezeCircle(x: x, y: y,);
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
        audio.itemEquipped(x, y);
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
    }
  }

}