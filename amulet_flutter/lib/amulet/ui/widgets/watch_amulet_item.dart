import 'package:amulet_engine/packages/common.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import '../../amulet.dart';
import 'amulet_item_image.dart';

class WatchAmuletItem extends StatelessWidget {
  final Watch<AmuletItem?> watch;
  final Amulet amulet;

  WatchAmuletItem(this.watch, this.amulet);

  @override
  Widget build(BuildContext context) => WatchBuilder(watch, (amuletItem) {
      const size = 50.0;
      return onPressed(
        action: amuletItem == null
            ? null
            : () => amulet.selectAmuletItem(amuletItem),
        onRightClick: amuletItem == null
            ? null
            : () => amulet.dropAmuletItem(amuletItem),
        child: Container(
          alignment: Alignment.center,
          color: Colors.white12,
          padding: const EdgeInsets.all(2),
          child: Container(
            alignment: Alignment.center,
            color: Colors.black12,
            padding: const EdgeInsets.all(2),
            child: amuletItem == null ? nothing : AmuletItemImage(amuletItem: amuletItem, scale: size / 32,),
          ),
        ),
      );
    });
}
