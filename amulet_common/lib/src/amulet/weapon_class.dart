import '../isometric/damage_type.dart';

enum WeaponClass {
  Sword(isMelee: true, damageType: DamageType.Slash),
  Staff(isMelee: true, damageType: DamageType.Bludgeon),
  Bow(isMelee: false, damageType: DamageType.Pierce);

  final bool isMelee;
  final DamageType damageType;
  const WeaponClass({
    required this.isMelee,
    required this.damageType,
  });
}
