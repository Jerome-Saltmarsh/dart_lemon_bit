import 'dart:math';

import '../classes.dart';
import '../constants.dart';
import '../enums.dart';
import '../enums/Weapons.dart';
import '../instances/settings.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../spawn.dart';
import '../state.dart';
import '../utils.dart';

void characterFireWeapon(Character character) {
  if (character.dead) return;
  if (character.shotCoolDown > 0) return;
  faceAimDirection(character);
  switch (character.weapon) {
    case Weapon.HandGun:
      spawnBullet(character);
      characterSpawnShell(character);
      character.state = CharacterState.Firing;
      character.shotCoolDown = settingsHandgunCooldown;
      gameEvents.add(GameEvent(character.x, character.y, GameEventType.Handgun_Fired));
      break;
    case Weapon.Shotgun:
      character.xVel += velX(character.aimAngle + pi, 1);
      character.yVel += velY(character.aimAngle + pi, 1);

      for (int i = 0; i < settingsShotgunBulletsPerShot; i++) {
        spawnBullet(character);
      }
      delayed((){
        characterSpawnShell(character);
      }, ms: 500);
      character.state = CharacterState.Firing;
      character.shotCoolDown = shotgunCoolDown;
      gameEvents.add(GameEvent(character.x, character.y, GameEventType.Shotgun_Fired));
      break;
    case Weapon.SniperRifle:
      spawnBullet(character);
      characterSpawnShell(character);
      character.state = CharacterState.Firing;
      character.shotCoolDown = settingsSniperCooldown;;
      gameEvents.add(GameEvent(character.x, character.y, GameEventType.SniperRifle_Fired));
      break;
    case Weapon.MachineGun:
      spawnBullet(character);
      characterSpawnShell(character);
      character.state = CharacterState.Firing;
      character.shotCoolDown = settings.machineGunCoolDown;;
      gameEvents.add(GameEvent(character.x, character.y, GameEventType.MachineGun_Fired));
      break;
  }

}
