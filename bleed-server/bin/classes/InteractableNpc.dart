import '../common/CharacterType.dart';
import '../common/SlotType.dart';
import '../enums/npc_mode.dart';
import 'Character.dart';
import 'Player.dart';

class InteractableNpc extends Character {
  final String name;

  Function(Player player) onInteractedWith;

  InteractableNpc({
      required this.name,
      required this.onInteractedWith,
      required double x,
      required double y,
      required int health,
      required SlotType weapon,
      int team = 1,
      NpcMode npcMode = NpcMode.Stand_Ground,
  })
      : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            ai: AI(mode: npcMode),
            health: health,
            weapon: weapon,
            team: team,
  );
}
