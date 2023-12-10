
import 'package:amulet_engine/mixins/src.dart';
import 'package:amulet_engine/packages/isomeric_engine.dart';

class AmuletFiend extends Character with Elemental {

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
    weaponCooldown: fiendType.weaponCooldown,
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
    experience = fiendType.experience;
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
  int get experience => fiendType.experience;

  @override
  int get maxHealth => fiendType.health;
}