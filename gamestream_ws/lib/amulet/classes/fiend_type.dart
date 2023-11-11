
import 'package:gamestream_ws/packages/common/src/isometric/character_type.dart';

enum FiendType {
  Fallen(
    level: 1,
    health: 3,
    damage: 1,
    characterType: CharacterType.Fallen,
  ),
  Skeleton(
    level: 2,
    health: 5,
    damage: 1,
    characterType: CharacterType.Skeleton,
  );

  final int level;
  final int health;
  final int damage;
  final int characterType;

  const FiendType({
    required this.level,
    required this.health,
    required this.damage,
    required this.characterType,
  });
}
