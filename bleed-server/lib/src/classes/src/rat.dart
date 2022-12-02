
import 'package:bleed_server/gamestream.dart';

class Rat extends AI {
  Rat({
    required int z,
    required int row,
    required int column,
    required Game game,
    required int team ,
    int health = 3,
    int damage = 1,
  }) : super(
      characterType: CharacterType.Rat,
      x: 0,
      y: 0,
      z: 0,
      health: health,
      weaponType: ItemType.Empty,
      team: team,
      damage: damage,
      speed: 3.0,
  ) {
    // indexZ = z;
    // indexRow = row;
    // indexColumn = column;
    Game.setGridPosition(position: this, z: z, row: row, column: column);
    spawnX = x;
    spawnY = y;
    spawnZ = this.z;
    destX = x;
    destY = y;
  }

  // @override
  // void write(Player player){
  //     player.writeCharacterRat(this);
  // }

  // @override
  // int get type => CharacterType.Rat;
}