import 'package:bleed_client/audio.dart';
import 'package:bleed_client/common/GameEventType.dart';
import 'package:bleed_client/functions/spawners/spawnArm.dart';
import 'package:bleed_client/functions/spawners/spawnBlood.dart';
import 'package:bleed_client/functions/spawners/spawnOrgan.dart';
import 'package:bleed_client/functions/spawners/spawnShell.dart';
import 'package:bleed_client/functions/spawners/spawnShotSmoke.dart';
import 'package:bleed_client/functions/spawners/spawnShrapnel.dart';
import 'package:bleed_client/functions/spawners/spawnZombieHead.dart';
import 'package:bleed_client/functions/spawners/spawnZombieLeg.dart';
import 'package:bleed_client/spawn.dart';
import 'package:flutter/services.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomBool.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameError.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules/game/actions.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_dispatch/instance.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/enums.dart';

import 'state.dart';


class GameEvents {

  final GameActions actions;
  final GameState state;

  GameEvents(this.actions, this.state);

  void register(){
    print("modules.game.events.register()");
    engine.callbacks.onLeftClicked = actions.performPrimaryAction;
    engine.callbacks.onPanStarted = actions.performPrimaryAction;
    engine.callbacks.onLongLeftClicked = actions.performPrimaryAction;
    engine.callbacks.onKeyPressed = onKeyPressed;
    registerPlayKeyboardHandler();

    game.player.characterType.onChanged(_onPlayerCharacterTypeChanged);
    game.type.onChanged(_onGameTypeChanged);
    game.player.uuid.onChanged(_onPlayerUuidChanged);
    game.player.alive.onChanged(_onPlayerAliveChanged);
    game.status.onChanged(_onGameStatusChanged);
    sub(_onGameError);
  }

  void onKeyPressed(LogicalKeyboardKey key){
     if (key == state.keyMap.perform){
        actions.performPrimaryAction();
        return;
     }

     if (key == state.keyMap.teleport){
        actions.teleportToMouse();
     }
  }

  void _onPlayerAliveChanged(bool value) {
    print("events.onPlayerAliveChanged($value)");
    if (value) {
      actions.cameraCenterPlayer();
    }
  }


  Future _onGameError(GameError error) async {
    print("events.onGameEvent('$error'");
    switch (error) {
      case GameError.PlayerId_Required:
        core.actions.disconnect();
        website.actions.showDialogLogin();
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
      engine.state.cursorType.value = CursorType.Precise;
    }else{
      engine.state.cursorType.value = CursorType.Basic;
    }
  }

  void _onGameTypeChanged(GameType type) {
    print('events.onGameTypeChanged($type)');
    core.actions.clearSession();
    engine.state.camera.x = 0;
    engine.state.camera.y = 0;
    engine.state.zoom = 1;
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
      // engine.state.drawCanvas = modules.game.render;
        engine.actions.fullScreenEnter();
        break;
      default:
        engine.state.drawCanvas = null;
        engine.actions.fullScreenExit();
        break;
    }
  }

  void onGameEvent(GameEventType type, double x, double y, double xv, double yv) {
    switch (type) {
      case GameEventType.Handgun_Fired:
        playAudioHandgunShot(x, y);
        spawnShell(x, y);
        break;
      case GameEventType.Shotgun_Fired:
        playAudioShotgunShot(x, y);
        spawnShell(x, y);
        spawnShotSmoke(x, y, xv, yv);
        break;
      case GameEventType.SniperRifle_Fired:
        playAudioSniperShot(x, y);
        spawnShell(x, y);
        break;
      case GameEventType.MachineGun_Fired:
        playAudioAssaultRifleShot(x, y);
        spawnShell(x, y);
        break;
      case GameEventType.Zombie_Hit:
        if (randomBool()) {
          playAudioZombieHit(x, y);
        }
        double s = 0.1;
        double r = 1;
        for (int i = 0; i < randomInt(2, 5); i++) {
          spawnBlood(x, y, 0.3,
              xv: xv * s + giveOrTake(r),
              yv: yv * s + giveOrTake(r),
              zv: randomBetween(0, 0.07));
        }
        break;
      case GameEventType.Player_Hit:
        if (randomBool()) {
          playAudioPlayerHurt(x, y);
        }
        double s = 0.1;
        double r = 1;
        for (int i = 0; i < randomInt(2, 5); i++) {
          spawnBlood(x, y, 0.3,
              xv: xv * s + giveOrTake(r),
              yv: yv * s + giveOrTake(r),
              zv: randomBetween(0, 0.07));
        }
        break;
      case GameEventType.Zombie_Killed:
        playAudioZombieDeath(x, y);
        double s = 0.15;
        double r = 1;
        for (int i = 0; i < randomInt(2, 5); i++) {
          spawnBlood(x, y, 0.3,
              xv: xv * s + giveOrTake(r),
              yv: yv * s + giveOrTake(r),
              zv: randomBetween(0, 0.07));
        }
        break;
      case GameEventType.Zombie_killed_Explosion:
        double s = 0.15;
        double r = 1;
        for (int i = 0; i < randomInt(2, 5); i++) {
          spawnBlood(x, y, 0.3,
              xv: xv * s + giveOrTake(r),
              yv: yv * s + giveOrTake(r),
              zv: randomBetween(0, 0.07));
        }
        spawnZombieHead(x, y, 0.5,
            xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
        spawnArm(x, y, 0.3,
            xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
        spawnArm(x, y, 0.3,
            xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
        spawnZombieLeg(x, y, 0.2,
            xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
        spawnZombieLeg(x, y, 0.2,
            xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
        spawnOrgan(x, y, 0.3,
            xv: xv * s + giveOrTake(r), yv: yv * s + giveOrTake(r));
        playAudioZombieDeath(x, y);
        break;
      case GameEventType.Zombie_Target_Acquired:
        playAudioZombieTargetAcquired(x, y);
        break;
      case GameEventType.Bullet_Hole:
        actions.spawnBulletHole(x.toDouble(), y.toDouble());
        break;
      case GameEventType.Zombie_Strike:
        playAudioZombieBite(x, y);
        double r = 1;
        double s = 0.15;
        for (int i = 0; i < randomInt(2, 4); i++) {
          spawnBlood(x, y, 0.3,
              xv: xv * s + giveOrTake(r),
              yv: yv * s + giveOrTake(r),
              zv: randomBetween(0, 0.07));
        }
        break;
      case GameEventType.Player_Death:
      // playAudioPlayerDeath(x, y);
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.Explosion:
        spawnExplosion(x, y);
        break;
      case GameEventType.FreezeCircle:
        spawnFreezeCircle(x: x, y: y,);
        break;
      case GameEventType.Teleported:
        actions.emitPixelExplosion(x, y);
        playAudioMagicalSwoosh18(x, y);
        break;
      case GameEventType.Blue_Orb_Fired:
        playAudio.sciFiBlaster1(x, y);
        break;
      case GameEventType.Objective_Reached:
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.EnemyTargeted:
        actions.emitPixelExplosion(x, y);
        break;
      case GameEventType.Arrow_Fired:
        playAudio.arrowFlyingPast6(x, y);
        break;
      case GameEventType.Clip_Empty:
        playAudioClipEmpty(x, y);
        return;
      case GameEventType.Reloaded:
        playAudioReloadHandgun(x, y);
        return;
      case GameEventType.Use_MedKit:
        playAudioUseMedkit(x, y);
        break;
      case GameEventType.Throw_Grenade:
        playAudioThrowGrenade(x, y);
        break;
      case GameEventType.Item_Acquired:
        playAudioAcquireItem(x, y);
        break;
      case GameEventType.Knife_Strike:
        playAudioKnifeStrike(x, y);
        break;
      case GameEventType.Health_Acquired:
        playAudioHeal(x, y);
        break;
      case GameEventType.Crate_Breaking:
        for (int i = 0; i < randomInt(4, 10); i++) {
          spawnShrapnel(x, y);
        }
        playAudioCrateBreaking(x, y);
        break;
      case GameEventType.Ammo_Acquired:
        playAudioGunPickup(x, y);
        break;
      case GameEventType.Credits_Acquired:
        playAudioCollectStar(x, y);
        break;
    }
  }

}