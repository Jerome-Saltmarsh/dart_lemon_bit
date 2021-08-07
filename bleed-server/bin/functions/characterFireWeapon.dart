import 'dart:math';

import '../classes.dart';
import '../enums.dart';
import '../enums/GameEventType.dart';
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
      Bullet bullet = spawnBullet(character);
      character.state = CharacterState.Firing;
      character.shotCoolDown = settingsHandgunCooldown;
      dispatch(GameEventType.Handgun_Fired, character.x, character.y, bullet.xv, bullet.yv);
      break;
    case Weapon.Shotgun:
      character.xv += velX(character.aimAngle + pi, 1);
      character.yv += velY(character.aimAngle + pi, 1);
      for (int i = 0; i < settingsShotgunBulletsPerShot; i++) {
        spawnBullet(character);
      }
      Bullet bullet = bullets.last;
      character.state = CharacterState.Firing;
      character.shotCoolDown = shotgunCoolDown;
      dispatch(GameEventType.Shotgun_Fired, character.x, character.y, bullet.xv, bullet.yv);
      break;
    case Weapon.SniperRifle:
      Bullet bullet = spawnBullet(character);
      character.state = CharacterState.Firing;
      character.shotCoolDown = settingsSniperCooldown;;
      dispatch(GameEventType.SniperRifle_Fired, character.x, character.y, bullet.xv, bullet.yv);
      break;
    case Weapon.MachineGun:
      Bullet bullet = spawnBullet(character);
      character.state = CharacterState.Firing;
      character.shotCoolDown = settings.machineGunCoolDown;;
      dispatch(GameEventType.MachineGun_Fired, character.x, character.y, bullet.xv, bullet.yv);
      break;
  }

}
