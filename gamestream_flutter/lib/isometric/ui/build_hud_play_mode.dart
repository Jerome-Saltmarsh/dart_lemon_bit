import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_inventory.dart';
import 'package:gamestream_flutter/isometric/ui/watch_inventory_visible.dart';

Widget buildHudPlayMode() {
    return Container(
      width: 500,
      height: 500,
      child: Stack(
        children: [
              Positioned(
                  right: 0,
                  top: 100,
                  child:  buildWatchInventoryVisible()
              ),
        ],
      ),
    );
}

Widget buildWatchInventoryVisible(){
  return watch(watchInventoryVisible, (bool inventoryVisible){
    if (!inventoryVisible) return const SizedBox();

    return Container(
        width: 200,
        height: 500,
        child: SingleChildScrollView(child: buildColumnPlayerWeapons()));
  });
}


