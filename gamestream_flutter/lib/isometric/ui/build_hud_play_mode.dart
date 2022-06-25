import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_character_editor.dart';
import 'package:gamestream_flutter/isometric/ui/watch_inventory_visible.dart';

Widget buildHudPlayMode() {
  return watch(watchInventoryVisible, (bool inventoryVisible){
     if (inventoryVisible) return buildHudInventory();
     return const SizedBox();
  });
}


