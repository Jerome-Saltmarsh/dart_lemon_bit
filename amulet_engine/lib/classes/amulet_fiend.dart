
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
    health: fiendType.health.toDouble(),
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
  double get attackDamage => fiendType.damage;

  @override
  int get attackDuration => fiendType.attackDuration;

  @override
  double get attackRange => fiendType.weaponRange;

  @override
  bool get roamEnabled => true;

  @override
  String get name => fiendType.name;

  @override
  double get maxHealth => fiendType.health.toDouble();

  @override
  double get runSpeed {
    final level = getSkillTypeLevel(SkillType.Run_Speed);
    final bonus = super.runSpeed * SkillType.getRunSpeed(level);
    return super.runSpeed + bonus;
  }

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

  int get regenMagic => getSkillTypeLevel(SkillType.Magic_Regen);

  int get regenHealth => getSkillTypeLevel(SkillType.Health_Regen);

  int getSkillTypeLevel(SkillType skillType) =>
      fiendType.skillTypes[skillType] ?? 0;
}