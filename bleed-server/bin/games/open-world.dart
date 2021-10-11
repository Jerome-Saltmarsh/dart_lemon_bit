import '../classes.dart';
import '../classes/Game.dart';
import '../classes/Inventory.dart';
import '../classes/Player.dart';
import '../common/GameType.dart';
import '../common/Quests.dart';
import '../instances/scenes.dart';
import '../utils/player_utils.dart';

class OpenWorld extends Game {
  late InteractableNpc npcMain;
  late InteractableNpc npcSmith;

  OpenWorld() : super(GameType.Open_World, scenes.town, 64) {
    npcMain = InteractableNpc(
        onInteractedWith: _onNpcInteractedWithMain, x: 0, y: 150, health: 100);

    npcSmith = InteractableNpc(
        onInteractedWith: _onNpcInteractedWithSmith, x: 0, y: 250, health: 100);
    npcs.add(npcMain);
    npcs.add(npcSmith);
  }

  void _onNpcInteractedWithMain(Player player) {
    switch (player.questMain) {
      case MainQuest.Introduction:
        player.message = "Welcome Traveller. "
            "You may rest easy, the walls of our town are well protected. "
            "If you need to earn some income I recommend talking to various folks. "
            "Equipment can be found at the armory, for a price of course. ";
        player.questMain = MainQuest.Talk_To_Smith;
        break;
      case MainQuest.Talk_To_Smith:
        player.message = "The smith is looking for a help with a matter";
        break;
      default:
        player.message = "I'm glad you are still with us traveller";
        break;
    }
  }

  void _onNpcInteractedWithSmith(Player player) {
    switch (player.questMain) {
      case MainQuest.Introduction:
        player.message = "Welcome to our town";
        player.questMain = MainQuest.Talk_To_Smith;
        break;
      case MainQuest.Talk_To_Smith:
        player.message = "Welcome outsider. Our supplies are running low. "
            "If you happen across some scrap metal while you are out, would you collect it for me"
            "I'll compensate you of course"
            "Here take this handgun, its last owner certainly no longer needs it... "
            "Just come back and talk to me again if you find yourself running low on ammunition";
        player.questMain = MainQuest.Scavenge_Supplies;
        player.rounds.handgun = 60;
        break;
      case MainQuest.Scavenge_Supplies:
        player.message = "Bring any metals and junk back you can find";
        break;
      default:
        player.message = "Good to see you well";
        break;
    }
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
  void onPlayerKilled(Player player) {}

  @override
  void update() {}
}
