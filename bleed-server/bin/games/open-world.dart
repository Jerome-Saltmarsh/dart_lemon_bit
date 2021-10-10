

import '../classes.dart';
import '../classes/Game.dart';
import '../classes/Inventory.dart';
import '../classes/Player.dart';
import '../common/GameType.dart';
import '../instances/scenes.dart';
import '../utils/player_utils.dart';

class OpenWorld extends Game {

  late InteractableNpc npcMain;

  OpenWorld() : super(GameType.Open_World, scenes.town, 64) {
    npcMain = InteractableNpc(
        onInteractedWith: _onNpcMainInteractedWith,
        x: 0,
        y: 150,
        health: 100
    );
    npcs.add(npcMain);
  }

  void _onNpcMainInteractedWith(Player player){
    player.message = "Hello World";
  }

  @override
  Player doSpawnPlayer() {
    return Player(
      x: 0,
      y: 0,
      inventory: Inventory(0, 0, []),
      clips: Clips(),
      rounds: Rounds(),
    );
  }

  @override
  bool gameOver() {
    return false;
  }

  @override
  void onPlayerKilled(Player player) {
  }

  @override
  void update() {

  }
}