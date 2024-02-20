
import '../common/src.dart';
import '../isometric/src.dart';


class AmuletFiend extends Character {

  FiendType fiendType;
  SkillType? activeSkillType;

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
    health = maxHealth;
  }

  @override
  int get characterType => fiendType.characterType;

  @override
  int get attackDamage => fiendType.damage;

  @override
  int get attackDuration => fiendType.attackDuration;

  @override
  double get attackRange => fiendType.weaponRange;

  @override
  String get name => fiendType.name;

  @override
  int get maxHealth => fiendType.health;

  @override
  double get runSpeed => fiendType.runSpeed * (conditionIsCold ? 0.5 : 1.0);

  @override
  bool get collidable => alive;

  @override
  double get chanceOfSetTarget => fiendType.chanceOfSetTarget;

  @override
  void attack() {
    clearPath();
    setCharacterStateStriking(
      duration: attackDuration, // TODO
    );
  }

}