

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
    weaponType: fiendType.weaponType,
    weaponDamage: fiendType.damage,
    weaponRange: fiendType.weaponRange,
    attackDuration: fiendType.attackDuration,
    health: fiendType.health,
  );

  void onFiendTypeChanged(){
    maxHealth = fiendType.health;
    health = maxHealth;
    name = fiendType.name;
    weaponDamage = fiendType.damage;
    attackDuration = fiendType.attackDuration;
    runSpeed = fiendType.runSpeed;
    chanceOfSetTarget = fiendType.chanceOfSetTarget;
    weaponType = fiendType.weaponType;
    weaponRange = fiendType.weaponRange;
    characterType = fiendType.characterType;
  }

  @override
  int get characterType => fiendType.characterType;

  @override
  double get weaponRange => fiendType.weaponRange;

  @override
  String get name => fiendType.name;

  @override
  int get maxHealth => fiendType.health;

  @override
  double get runSpeed => super.runSpeed * (isStatusCold ? 0.5 : 1.0);
}