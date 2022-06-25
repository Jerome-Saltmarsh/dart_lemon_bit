import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_panel_store.dart';
import 'package:gamestream_flutter/isometric/ui/watch_inventory_visible.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:gamestream_flutter/ui/builders/build_text_box.dart';

Widget buildHudPlayMode() {
  return Stack(
    children: [
      Positioned(top: 0, right: 0, child: buildPanelMenu()),
      Positioned(top: 50, left: 0, child: buildPanelStore()),
      Positioned(top: 50, right: 0, child: buildWatchInventoryVisible()),
      buildPanelWriteMessage(),
    ]
  );
}

Widget buildWatchInventoryVisible(){
  return watch(inventoryVisible, (bool inventoryVisible){
    if (!inventoryVisible) return const SizedBox();

    return Container(
        width: 200,
        height: 500,
        child: SingleChildScrollView(child: buildColumnPlayerWeapons()));
  });
}


