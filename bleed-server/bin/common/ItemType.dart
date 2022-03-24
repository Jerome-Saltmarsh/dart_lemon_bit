import 'WeaponType.dart';

final Map<ItemType, WeaponType> _itemTypeWeaponType = {
  ItemType.Handgun: WeaponType.HandGun,
  ItemType.Shotgun: WeaponType.Shotgun,
};

enum ItemType {
  Health,
  Handgun,
  Shotgun,
  Orb_Ruby,
  Orb_Topaz,
  Orb_Emerald,
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

