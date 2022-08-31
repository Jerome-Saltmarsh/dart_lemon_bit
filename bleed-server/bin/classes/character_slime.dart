
import '../common/character_type.dart';
import 'ai.dart';
import 'game.dart';
import 'player.dart';
import 'weapon.dart';

/// The most basic enemy.
/// Easy to kill but plentiful
class CharacterSlime extends AI {

  CharacterSlime({
    required double x,
    required double y,
    required double z,
    required int health,
    required Weapon weapon,
    required Game game,
  }) : super(
      x: x,
      y: y,
      z: z,
      health: health,
      weapon: weapon,
      game: game,
      type: CharacterType.Slime,
  ) {
  }

  @override
  void write(Player player) {

  }
}