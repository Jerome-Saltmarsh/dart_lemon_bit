import 'package:gamestream_flutter/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';
import 'package:golden_ratio/constants.dart';

class MMOItemImage extends StatelessWidget {
  final double size;
  final MMOItem? item;
  final double scale;

  MMOItemImage({
    required this.item,
    required this.size,
    this.scale = goldenRatio_1381,
  });

  @override
  Widget build(BuildContext context) =>
      item == null ? Container(
        margin: const EdgeInsets.all(4),
        child: GSContainer(
            width: size,
            height: size,
            child: buildText('-'),
        ),
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
            child: Container(
              color: GS_CONTAINER_COLOR,
              margin: const EdgeInsets.all(4),
              child: ItemImage(
                size: size,
                type: item!.type,
                subType: item!.subType,
                scale: scale,
              ),
            )
        );
}