
import 'package:amulet_flutter/packages/common/src/isometric/weapon_type.dart';

const atlasSrcWeapons = <int, List<double>>{
  WeaponType.Unarmed : AtlasSrcWeapons.Unarmed,
  WeaponType.Sword : AtlasSrcWeapons.Sword,
  WeaponType.Bow : AtlasSrcWeapons.Bow,
  WeaponType.Grenade : AtlasSrcWeapons.Grenade,
  WeaponType.Crossbow : AtlasSrcWeapons.Crossbow,
  WeaponType.Staff : AtlasSrcWeapons.Staff,
  WeaponType.Musket : AtlasSrcWeapons.Musket,
  WeaponType.Revolver : AtlasSrcWeapons.Revolver,
  WeaponType.Hammer : AtlasSrcWeapons.Hammer,
  WeaponType.Pickaxe : AtlasSrcWeapons.Pickaxe,
  WeaponType.Knife : AtlasSrcWeapons.Knife,
  WeaponType.Axe : AtlasSrcWeapons.Axe,
  WeaponType.Spell_Thunderbolt: [1, 1, 30, 30, 1, 0.5]
};

class AtlasSrcWeapons {
  static const Handgun = <double> [
    0,  // x
    0,    // y
    48,   // width
    32,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Shotgun = <double> [
    48,  // x
    0,    // y
    96,   // width
    32,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Sniper_Rifle = <double> [
    144,  // x
    0,    // y
    96,   // width
    32,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Flame_Thrower = <double> [
    240,  // x
    0,    // y
    96,   // width
    48,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Unarmed = <double> [
    3,  // x
    70,    // y
    25,   // width
    20,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Smg = <double> [
    38,  // x
    67,    // y
    21,   // width
    11,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Machine_Gun = <double> [
    32,  // x
    81,    // y
    31,   // width
    13,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Sword = <double> [
    67,  // x
    68,    // y
    25,   // width
    25,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Bow = <double> [
    4,  // x
    99,    // y
    9,   // width
    26,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Plasma_Pistol = <double> [
    338,  // x
    9,    // y
    61,   // width
    51,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Crowbar = <double> [
    19,  // x
    98,    // y
    26,   // width
    28,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Grenade = <double> [
    6,  // x
    259,    // y
    7,   // width
    10,   // height
    2,  // scale
    0.5, // anchorY
  ];

  static const Bazooka = <double> [
    7,  // x
    33,    // y
    81,   // width
    30,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Minigun = <double> [
    5,  // x
    130,    // y
    35,   // width
    12,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Crossbow = <double> [
    51,  // x
    100,    // y
    26,   // width
    26,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Staff = <double> [
    84,  // x
    98,    // y
    26,   // width
    26,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Musket = <double> [
    56,  // x
    130,    // y
    32,   // width
    10,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Revolver = <double> [
    9,  // x
    147,    // y
    16,   // width
    10,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Pistol = <double> [
    33,  // x
    150,    // y
    30,   // width
    19,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Plasma_Rifle = <double> [
    97,  // x
    33,    // y
    94,   // width
    53,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Hammer = <double> [
    3,  // x
    166,    // y
    26,   // width
    20,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Pickaxe = <double> [
    3,  // x
    196,    // y
    26,   // width
    26,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Knife = <double> [
    73,  // x
    150,    // y
    16,   // width
    5,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Axe = <double> [
    5,  // x
    227,    // y
    26,   // width
    26,   // height
    1,  // scale
    0.5, // anchorY
  ];

  static const Rifle = <double> [
    41,  // x
    179,    // y
    32,   // width
    11,   // height
    1,  // scale
    0.5, // anchorY
  ];
}
