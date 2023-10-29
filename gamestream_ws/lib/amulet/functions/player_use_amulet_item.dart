import 'package:gamestream_ws/amulet/classes/amulet_player.dart';
import 'package:gamestream_ws/packages/common/src.dart';


void playerUseAmuletItem(AmuletPlayer player, AmuletItem amuletItem) {

  final amuletItemLevel = player.getAmuletItemLevel(amuletItem);

  if (amuletItemLevel == null) {
    player.writeGameError(GameError.Insufficient_Elements);
    return;
  }

  switch (amuletItem.selectAction) {
    case AmuletItemAction.Equip:
      throw Exception();
    case AmuletItemAction.Caste:

      if (amuletItemLevel.performDuration <= 0){
        throw Exception('stats.performDuration <= 0 ${amuletItem} ${amuletItemLevel}');
      }

      player.setCharacterStateCasting(
          duration: amuletItemLevel.performDuration,
      );
      break;
    case AmuletItemAction.Targeted_Enemy:
      if (player.target == null) {
        player.deselectActivatedPower();
        return;
      }
      player.setCharacterStateStriking(
        duration: amuletItemLevel.performDuration,
      );
      break;
    case AmuletItemAction.Targeted_Ally:
      if (player.target == null) {
        player.deselectActivatedPower();
        return;
      }
      player.setCharacterStateStriking(
        duration: amuletItemLevel.performDuration,
      );
      break;
    case AmuletItemAction.Positional:
      player.setCharacterStateStriking(
        duration: amuletItemLevel.performDuration,
      );
      break;
    case AmuletItemAction.None:
// TODO: Handle this case.
    case AmuletItemAction.Instant:
      // TODO: Handle this case.
    case AmuletItemAction.Consume:
      // TODO: Handle this case.
  }
}
