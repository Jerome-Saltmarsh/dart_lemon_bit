import 'package:gamestream_ws/amulet/classes/amulet_player.dart';
import 'package:gamestream_ws/packages/common/src.dart';


void playerUseAmuletItem(AmuletPlayer player, AmuletItem item) {

  switch (item.selectAction) {
    case AmuletItemAction.Equip:
      throw Exception();
    case AmuletItemAction.Caste:
      if (item.performDuration < 0) {
        throw Exception('item.performDuration < 0');
      }
      // setCharacterStateStriking(
      //   character: player,
      //   actionFrame: item.actionFrame,
      //   duration: item.performDuration,
      // );
      player.setCharacterStateCasting(
          duration: item.performDuration,
          // actionFrame: item.actionFrame,
      );
      break;
    case AmuletItemAction.Targeted_Enemy:
      if (player.target == null) {
        player.deselectActivatedPower();
        return;
      }
      player.setCharacterStateStriking(
        duration: item.performDuration,
      );
      break;
    case AmuletItemAction.Targeted_Ally:
      if (player.target == null) {
        player.deselectActivatedPower();
        return;
      }
      player.setCharacterStateStriking(
        duration: item.performDuration,
      );
      break;
    case AmuletItemAction.Positional:
      player.setCharacterStateStriking(
        duration: item.performDuration,
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
