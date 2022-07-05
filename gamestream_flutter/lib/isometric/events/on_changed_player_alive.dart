import 'package:gamestream_flutter/isometric/actions/action_inventory_close.dart';

void onChangedPlayerAlive(bool value) {
  if (!value) {
    actionInventoryClose();
  }
}
