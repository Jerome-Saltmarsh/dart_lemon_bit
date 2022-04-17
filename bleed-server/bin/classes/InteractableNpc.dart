import '../common/CharacterType.dart';
import '../enums/npc_mode.dart';
import 'Character.dart';
import 'Player.dart';

class InteractableNpc extends AI {
  final String name;

  Function(Player player) onInteractedWith;

  InteractableNpc({
      required this.name,
      required this.onInteractedWith,
      required double x,
      required double y,
      required int health,
      required int weapon,
      int team = 1,
      NpcMode npcMode = NpcMode.Stand_Ground,
  })
      : super(
            type: CharacterType.Human,
            x: x,
            y: y,
            mode: npcMode,
            health: health,
            weapon: weapon,
            team: team,
  );
}
