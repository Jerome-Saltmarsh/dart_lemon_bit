
import '../common/library.dart';
import 'ai.dart';
import 'player.dart';
import 'weapon.dart';

class AISlime extends AI {

  AISlime({
    required double x,
    required double y,
    required double z,
    required int health,
    required int team,
  }) : super(
      x: x,
      y: y,
      z: z,
      health: health,
      weapon: Weapon(
          type: ItemType.Empty,
          damage: 1,
          capacity: 0,
          duration: 10,
          range: 50,
      ),
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