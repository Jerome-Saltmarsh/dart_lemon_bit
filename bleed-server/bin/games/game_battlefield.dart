
import '../classes/library.dart';
import '../common/library.dart';

/// In battlefield there are two teams of up to 16 players
/// The goal of each team is to capture the enemies fortress flag
/// There are sub fortress flags which when captured spawn additional units
/// or apply bonuses to existing units spawned etc
///
/// To keep things simple there is no character development,
/// rather we simply choose one of 5 characters at the beginning and upgrade them
/// by capturing flag outposts
///
/// Its possible to fast travel between outposts but this costs fast travel bar
/// which then has to refill before it can be done again
///
/// Outpost Types
/// Base - Main base, spawn 5 units per 30 seconds
/// Barrack - Spawns 3 units per 30 seconds
/// Outpost - Spawns 2 units per 30 seconds
/// Smith - Spawned units have +1 damage
class GameBattleField extends Game {

  static const time = 12 * 60 * 60;

  GameBattleField(Scene scene) : super(scene);

  @override
  int getTime() => time;

  void onPlayerJoined(Player player) {
     player.equippedType = TechType.Shotgun;
  }
}