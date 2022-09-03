
import '../common/character_type.dart';
import '../common/library.dart';
import 'ai.dart';
import 'game.dart';
import 'player.dart';
import 'weapon.dart';

class Rat extends AI {
  Rat({
    required int z,
    required int row,
    required int column,
    required Game game,
    int health = 3,
    int damage = 1,
    int team = 10,
  }) : super(
      x: 0,
      y: 0,
      z: 0,
      health: health,
      weapon: Weapon(type: WeaponType.Unarmed, damage: damage),
      team: team,
      game: game,
  ) {
    indexZ = z;
    indexRow = row;
    indexColumn = column;
    spawnX = x;
    spawnY = y;
    spawnZ = this.z;
    destX = x;
    destY = y;
  }

  @override
  void write(Player player){
      player.writeRat(this);
  }

  @override
  int get type => CharacterType.Rat;
}