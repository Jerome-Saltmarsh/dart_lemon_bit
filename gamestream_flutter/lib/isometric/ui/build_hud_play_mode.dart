import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_panel_store.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_toggle_inventory.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_health.dart';
import 'package:gamestream_flutter/isometric/watches/inventory_visible.dart';
import 'package:gamestream_flutter/isometric/ui/controls/build_control_player_experience.dart';
import 'package:gamestream_flutter/ui/builders/build_text_box.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/screen.dart';

Widget buildHudPlayMode() {
  return Stack(
    children: [
      Positioned(top: 50, left: 0, child: buildPanelStore()),
      Positioned(top: 50, right: 0, child: buildWatchInventoryVisible()),
      Positioned(top: 50, left: 0, child: buildPanelStore()),
      Positioned(bottom: 50, left: 0, child: buildWatchMouseTargetName()),
      Positioned(bottom: 8, right: 8, child: buildButtonToggleInventory()),
      Positioned(bottom: 8, child: Container(
        width: screen.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildControlPlayerExperience(),
            width6,
            buildControlPlayerHealth(),
          ],
        ),
      )),
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
        child: Container(
           color: colours.redDark1,
           height: 50,
           width: 100,
           alignment: Alignment.centerLeft,
           child: Stack(
             children: [
               watch(player.mouseTargetHealth, (double health){
                  return Container(
                    height: 50,
                    width: 100 * health,
                    color: Colors.red,
                  );
               }),
               Container(
                   width: 100,
                   height: 50,
                   alignment: Alignment.center,
                   padding: const EdgeInsets.only(left: 6),
                   child: text(name)),
             ],
           ),
        ),
      );
      // return Container(
      //     alignment: Alignment.center,
      //     width: engine.screen.width,
      //     child: container(child: name));
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


