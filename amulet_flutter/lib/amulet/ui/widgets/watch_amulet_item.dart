import 'package:amulet_engine/packages/common.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'amulet_item_image.dart';

class WatchAmuletItem extends StatelessWidget {
  final Watch<AmuletItem?> watch;

  WatchAmuletItem(this.watch);

  @override
  Widget build(BuildContext context) {
    const size = 50.0;
    return Container(
      alignment: Alignment.center,
      color: Colors.white12,
      padding: const EdgeInsets.all(2),
      child: Container(
        alignment: Alignment.center,
        color: Colors.black12,
        padding: const EdgeInsets.all(2),
        child: WatchBuilder(watch,
                (t) => t == null ? nothing : AmuletItemImage(amuletItem: t, scale: size / 32,)
        ),
      ),
    );
  }
}
