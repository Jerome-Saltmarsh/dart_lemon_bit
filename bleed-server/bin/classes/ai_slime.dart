
import '../common/ServerResponse.dart';
import '../common/attack_type.dart';
import '../common/character_type.dart';
import 'ai.dart';
import 'game.dart';
import 'player.dart';
import 'weapon.dart';

class AISlime extends AI {

  AISlime({
    required double x,
    required double y,
    required double z,
    required int health,
    required Game game,
    required int team,
  }) : super(
      x: x,
      y: y,
      z: z,
      health: health,
      weapon: Weapon(
          type: AttackType.Unarmed,
          damage: 1,
          capacity: 0,
          duration: 10,
          range: 50,
      ),
      game: game,
      team: team,
  );

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.Character_Slime);
    player.writeCharacter(player, this);
  }

  @override
  int get type => CharacterType.Slime;
}