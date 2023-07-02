import 'dart:typed_data';

import 'package:bleed_common/src.dart';

class TemplateAnimation {

  static const Frame_Changing = 4;
  static const Frame_Aiming_One_Handed = 7;
  static const Frame_Aiming_Two_Handed = 5;
  static const Frame_Aiming_Sword = 9;

  static final Uint8List Running1 = (){
    final list = Uint8List(4);
    list[0] = 12;
    list[1] = 13;
    list[2] = 14;
    list[3] = 15;
    return list;
  }();

  static final Uint8List Running2 = (){
    final list = Uint8List(4);
    list[0] = 16;
    list[1] = 17;
    list[2] = 18;
    list[3] = 19;
    return list;
  }();

  static Uint8List Idle = (){
    final list = Uint8List(1);
    list[0] = 1;
    return list;
  }();

  static Uint8List Hurt = (){
    final list = Uint8List(1);
    list[0] = 3;
    return list;
  }();

  static Uint8List Changing = (){
    final list = Uint8List(1);
    list[0] = 4;
    return list;
  }();

  static Uint8List Firing_Bow = (){
    final list = Uint8List(9);
    list[0] = 5;
    list[1] = 5;
    list[2] = 5;
    list[3] = 5;
    list[4] = 8;
    list[5] = 8;
    list[6] = 8;
    list[7] = 8;
    list[8] = 10;
    return list;
  }();

  static List<int> Firing_One_Handed_Firearm = (){
    final frames = Uint8List(4);
    frames[0] = 8;
    frames[1] = 9;
    frames[2] = 9;
    frames[3] = 8;
    return frames;
  }();

  static const FiringShotgun = [
    6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 8, 8, 8, 8
  ];

  static const Firing_Two_Handed_Firearm = [
    6, 7, 7, 6];

  static const FiringMinigun = [6];

  static const Punch = [
    10, 10, 10, 10, 10, 11
  ];

  static const Throwing = [
    10, 10, 10, 10, 10, 11
  ];

  static Uint8List StrikingBlade = (){
    final list = Uint8List(7);
    list[0] = 10;
    list[1] = 10;
    list[2] = 10;
    list[3] = 11;
    list[4] = 11;
    list[5] = 11;
    list[6] = 11;
    return list;
  }();

  static List<int> getAttackAnimation(int weaponType){

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
      WeaponType.Desert_Eagle,
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
      return StrikingBlade;
    }

    if (WeaponType.Bow == weaponType){
      return Firing_Bow;
    }
    if (weaponType == WeaponType.Grenade) {
      return Punch;
    }

    throw Exception('TemplateAnimation.getAttackAnimation(${WeaponType.getName(weaponType)})');
  }
}
