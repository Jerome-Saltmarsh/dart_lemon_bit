import 'WeaponType.dart';

final Map<ItemType, WeaponType> _itemTypeWeaponType = {
  ItemType.Handgun: WeaponType.HandGun,
  ItemType.Shotgun: WeaponType.Shotgun,
  ItemType.SniperRifle: WeaponType.SniperRifle,
  ItemType.Assault_Rifle: WeaponType.AssaultRifle,
};

enum ItemType {
  None,
  Armour,
  Health,
  Grenade,
  Credits,
  Handgun,
  Shotgun,
  SniperRifle,
  Assault_Rifle,
}

final List<ItemType> itemTypes = ItemType.values;


extension ItemTypeExtension on ItemType {
  bool get isWeapon {
    return weaponType != null;
  }

  WeaponType? get weaponType {
    return _itemTypeWeaponType[this];
  }
}