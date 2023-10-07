import 'package:gamestream_ws/amulet/amulet_player.dart';
import 'use_amulet_item.dart';

void useActivatedPower(AmuletPlayer player) {
  final activatedPowerIndex = player.activatedPowerIndex;
  if (activatedPowerIndex < 0) {
    throw Exception('activatedPowerIndex < 0 : $activatedPowerIndex < 0');
  }

  final weapons = player.weapons;

  if (activatedPowerIndex >= weapons.length) {
    throw Exception('invalid weapon index: $activatedPowerIndex');
  }

  final weapon = weapons[activatedPowerIndex];
  final item = weapon.item;

  if (item == null) {
    throw Exception();
  }

  useAmuletItem(player, item);
}
