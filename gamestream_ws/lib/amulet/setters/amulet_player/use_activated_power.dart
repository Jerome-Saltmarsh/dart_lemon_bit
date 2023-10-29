import 'package:gamestream_ws/amulet/classes/amulet_player.dart';
import '../../functions/player_use_amulet_item.dart';

void amuletPlayerUseActivatedPower(AmuletPlayer player) {
  final activatedPowerIndex = player.activatedPowerIndex;
  if (activatedPowerIndex < 0) {
    throw Exception('activatedPowerIndex < 0 : $activatedPowerIndex < 0');
  }

  final weapons = player.weapons;

  if (activatedPowerIndex >= weapons.length) {
    throw Exception('invalid weapon index: $activatedPowerIndex');
  }

  final itemSlot = weapons[activatedPowerIndex];
  final item = itemSlot.amuletItem;

  if (item == null) {
    throw Exception();
  }

  final stats = player.getAmuletItemLevel(item);
  if (stats != null) {
    itemSlot.cooldown = stats.cooldown;
  }
  playerUseAmuletItem(player, item);
}
