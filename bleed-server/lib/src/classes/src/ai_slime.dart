
import 'package:bleed_server/gamestream.dart';

class AISlime extends AI {

  AISlime({
    required double x,
    required double y,
    required double z,
    required int health,
    required int team,
  }) : super(
      characterType: CharacterType.Slime,
      x: x,
      y: y,
      z: z,
      health: health,
      weaponType: ItemType.Empty,
      team: team,
      damage: 5,
      speed: 3.0,
  );

  // @override
  // void write(Player player) {
  //   player.writeByte(ServerResponse.Character_Slime);
  //   player.writeCharacter(player, this);
  // }

  // @override
  // int get type => CharacterType.Slime;
}