import 'WeaponType.dart';

final Map<ItemType, WeaponType> _itemTypeWeaponType = {
  ItemType.Handgun: WeaponType.HandGun,
  ItemType.Shotgun: WeaponType.Shotgun,
  ItemType.SniperRifle: WeaponType.SniperRifle,
  ItemType.Assault_Rifle: WeaponType.AssaultRifle,
};

enum ItemType {
  Box,
  Armour,
  Health,
  Grenade,
  Credits,
  Handgun,
  Shotgun,
  SniperRifle,
  Assault_Rifle,
  Orb_Emerald,
  Orb_Ruby,
  Orb_Topaz,
}

final List<ItemType> itemTypes = ItemType.values;

final List<ItemType> orbItemTypes = [
  ItemType.Orb_Ruby,
  ItemType.Orb_Topaz,
  ItemType.Orb_Emerald,
];


extension ItemTypeExtension on ItemType {
  bool get isWeapon {
    return weaponType != null;
  }

  WeaponType? get weaponType {
    return _itemTypeWeaponType[this];
  }
}

