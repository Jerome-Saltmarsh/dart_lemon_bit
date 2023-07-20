import 'dart:typed_data';
import 'package:gamestream_flutter/common.dart';

class WeaponSubType {
  static const Melee_One_Handed = 0;
  static const Melee_Two_Handed = 1;
  static const Firearm_One_Handed = 3;
  static const Firearm_Two_Handed = 2;
  static const Bow = 3;
}

class TemplateAnimation {

  static const Frame_Changing = 4;
  static const Frame_Aiming_One_Handed = 7;
  static const Frame_Aiming_Two_Handed = 5;
  static const Frame_Aiming_Sword = 9;
  static const Running1 = [12, 13, 14, 15];
  static const Running2 = [16, 17, 18, 19];
  static const Idle = [1];
  static const Hurt = [3];
  static const Changing = [1];
  static const Firing_Bow = [
    5, 5, 5, 5, 8, 8, 8, 8, 5
  ];

  static const Firing_One_Handed_Firearm = [8, 9, 9, 8];

  static const FiringShotgun = [
    6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 8, 8, 8, 8
  ];

  static const Firing_Two_Handed_Firearm = [
    6, 7, 7, 6];

  static const FiringMinigun = [6];

  static const Punch = [
    10, 10, 10, 10, 10, 11
  ];

  static const Throwing = Punch;

  static const Striking_Blade = [10, 10, 10, 11];

  static List<int> getWeaponPerformAnimation(int weaponType){

    if (weaponType == WeaponType.Unarmed) {
      return Punch;
    }

    if (const [
      WeaponType.Shotgun,
      WeaponType.Flame_Thrower,
      WeaponType.Bazooka,
    ].contains(weaponType)) {
      return FiringShotgun;
    }

    if (const [
      WeaponType.Handgun,
      WeaponType.Pistol,
      WeaponType.Plasma_Pistol,
      WeaponType.Smg,
    ].contains(weaponType)) {
      return Firing_One_Handed_Firearm;
    }

    if (const [
      WeaponType.Rifle,
      WeaponType.Sniper_Rifle,
      WeaponType.Machine_Gun,
    ].contains(weaponType)) {
      return Firing_Two_Handed_Firearm;
    }

    if (WeaponType.isMelee(weaponType)) {
      return Striking_Blade;
    }

    if (weaponType == WeaponType.Grenade){
      return Throwing;
    }

    if (WeaponType.Bow == weaponType) {
      return Firing_Bow;
    }

    if (weaponType == WeaponType.Grenade) {
      return Punch;
    }

    throw Exception('TemplateAnimation.getAttackAnimation(${WeaponType.getName(weaponType)})');
  }
}
