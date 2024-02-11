

import '../packages/isomeric_engine.dart';

class AmuletFiend extends Character {

  FiendType fiendType;

  AmuletFiend({
    required super.x,
    required super.y,
    required super.z,
    required super.team,
    required this.fiendType,
  }) : super (
    characterType: fiendType.characterType,
    weaponType: WeaponType.Unarmed,
    attackDamage: fiendType.damage,
    attackRange: fiendType.weaponRange,
    attackDuration: fiendType.attackDuration,
    health: fiendType.health,
  ) {
    respawnDurationTotal = -1;
    weaponHitForce = 2.0;
  }

  void onFiendTypeChanged(){
    maxHealth = fiendType.health;
    health = maxHealth;
    name = fiendType.name;
    attackDamage = fiendType.damage;
    attackDuration = fiendType.attackDuration;
    runSpeed = fiendType.runSpeed;
    chanceOfSetTarget = fiendType.chanceOfSetTarget;
    attackRange = fiendType.weaponRange;
    characterType = fiendType.characterType;
  }

  @override
  int get characterType => fiendType.characterType;

  @override
  double get attackRange => fiendType.weaponRange;

  @override
  String get name => fiendType.name;

  @override
  int get maxHealth => fiendType.health;

  @override
  double get runSpeed => super.runSpeed * (isAilmentCold ? 0.5 : 1.0);
}