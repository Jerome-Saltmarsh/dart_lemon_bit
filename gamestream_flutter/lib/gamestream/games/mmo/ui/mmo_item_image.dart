import 'package:gamestream_flutter/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';

class MMOItemImage extends StatelessWidget {
  final double size;
  final MMOItem? item;

  MMOItemImage({required this.item, required this.size});

  @override
  Widget build(BuildContext context) =>
      item == null ? GSContainer(
          width: size,
          height: size,
          child: buildText('-'),
      ) :
        MouseRegion(
            onEnter: (_){
              gamestream.games.mmo.itemHover.value = item;
            },
            onExit: (_){
              if (gamestream.games.mmo.itemHover.value != item)
                return;
              gamestream.games.mmo.itemHover.value = null;
            },
            child: ItemImage(size: size, type: item!.type, subType: item!.subType));
}