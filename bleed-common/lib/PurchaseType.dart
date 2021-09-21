import 'constants.dart';

enum PurchaseType {
  Weapon_Handgun,
  Weapon_Shotgun,
  Weapon_AssaultRifle,
  Weapon_SniperRifle,
  Ammo_Handgun,
  Ammo_Shotgun,
  Ammo_SniperRifle,
  Ammo_AssaultRifle,
}

int getPurchaseTypeCost(PurchaseType purchaseType){
  switch(purchaseType){
    case PurchaseType.Weapon_Handgun:
      return prices.weapon.handgun;
    case PurchaseType.Weapon_Shotgun:
      return prices.weapon.shotgun;
    case PurchaseType.Weapon_SniperRifle:
      return prices.weapon.shotgun;
    case PurchaseType.Weapon_AssaultRifle:
      return prices.weapon.assaultRifle;
    case PurchaseType.Ammo_Handgun:
      return prices.ammo.handgun;
    case PurchaseType.Ammo_Shotgun:
      return prices.ammo.shotgun;
    case PurchaseType.Ammo_SniperRifle:
      return prices.ammo.sniperRifle;
    case PurchaseType.Ammo_AssaultRifle:
      return prices.ammo.assaultRifle;
  }
}