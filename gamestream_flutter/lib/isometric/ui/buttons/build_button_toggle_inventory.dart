import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/icons.dart';
import 'package:gamestream_flutter/isometric/watches/inventory_visible.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildButtonToggleInventory() {
  return onPressed(
    callback: toggleInventoryVisible,
    child: WatchBuilder(inventoryVisible, (bool inventoryVisible) {
      if (inventoryVisible){
        return icons.bag;
      }
      return icons.bagGray;
    }),
  );
}