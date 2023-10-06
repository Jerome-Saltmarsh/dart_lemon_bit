import 'package:gamestream_ws/amulet/amulet_player.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_item.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_power_mode.dart';

import '../../../isometric/functions/character/set_character_state_striking.dart';

void useAmuletItem(AmuletPlayer player, AmuletItem item) {
  switch (item.selectAction) {
    case AmuletItemSelectAction.Equip:
      throw Exception();
    case AmuletItemSelectAction.Caste:
      if (item.actionFrame < 0) {
        throw Exception('item.actionFrame < 0');
      }
      if (item.performDuration < 0) {
        throw Exception('item.performDuration < 0');
      }
      setCharacterStateStriking(
        character: player,
        actionFrame: item.actionFrame,
        duration: item.performDuration,
      );
      break;
    case AmuletItemSelectAction.Targeted_Enemy:
      if (player.target == null) {
        player.deselectActivatedPower();
        return;
      }
      player.actionFrame = item.actionFrame;
      setCharacterStateStriking(
        character: player,
        actionFrame: item.actionFrame,
        duration: item.performDuration,
      );
      break;
    case AmuletItemSelectAction.Targeted_Ally:
      if (player.target == null) {
        player.deselectActivatedPower();
        return;
      }
      setCharacterStateStriking(
        character: player,
        actionFrame: item.actionFrame,
        duration: item.performDuration,
      );
      break;
    case AmuletItemSelectAction.Positional:
      setCharacterStateStriking(
        character: player,
        duration: item.performDuration,
        actionFrame: item.actionFrame,
      );
      player.weaponType = item.subType;
      break;
    case AmuletItemSelectAction.None:
// TODO: Handle this case.
    case AmuletItemSelectAction.Instant:
      // TODO: Handle this case.
    case AmuletItemSelectAction.Consume:
      // TODO: Handle this case.
  }
}
