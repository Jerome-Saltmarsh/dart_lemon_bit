import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';
import 'package:gamestream_flutter/isometric/ui/build_panel_store.dart';
import 'package:gamestream_flutter/isometric/ui/watch_inventory_visible.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';
import 'package:gamestream_flutter/ui/builders/build_text_box.dart';
import 'package:lemon_engine/engine.dart';


Widget buildHudPlayMode() {
  return Stack(
    children: [
      Positioned(top: 0, right: 0, child: buildPanelMenu()),
      Positioned(top: 50, left: 0, child: buildPanelStore()),
      Positioned(top: 50, right: 0, child: buildWatchInventoryVisible()),
      Positioned(top: 50, left: 0, child: buildPanelStore()),
      Positioned(bottom: 50, left: 0, child: buildWatchMouseTargetName()),
      buildPanelWriteMessage(),
    ]
  );
}

Widget buildWatchMouseTargetName(){
   return watch(player.mouseTargetName, (String? name){
      if (name == null) return SizedBox();
      return Container(
          alignment: Alignment.center,
          width: engine.screen.width,
          child: container(child: name));
   });
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


