
import 'package:gamestream_ws/packages/common/src/isometric/character_type.dart';

enum FiendType {
  Fallen(
    level: 1,
    health: 3,
    damage: 1,
    characterType: CharacterType.Fallen,
    attackDuration: 20,
    experience: 1,
    runSpeed: 1.0,
  ),
  Skeleton(
    level: 2,
    health: 5,
    damage: 1,
    characterType: CharacterType.Skeleton,
    attackDuration: 20,
    experience: 2,
    runSpeed: 1.0,
  );

  final int level;
  final int health;
  final int damage;
  final int attackDuration;
  final int characterType;
  final int experience;
  final double runSpeed;

  const FiendType({
    required this.level,
    required this.health,
    required this.damage,
    required this.characterType,
    required this.attackDuration,
    required this.experience,
    required this.runSpeed,
  });
}
