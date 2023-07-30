import 'package:flutter/material.dart';
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/item_image.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';
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
      item == null ? buildText('-', color: Colors.white54) :
        IsometricBuilder(
          builder: (context, isometric) {
            return MouseRegion(
                onEnter: (_){
                  isometric.games.mmo.itemHover.value = item;
                },
                onExit: (_){
                  if (isometric.games.mmo.itemHover.value != item)
                    return;
                  isometric.games.mmo.itemHover.value = null;
                },
                child: ItemImage(
                  size: size,
                  type: item!.type,
                  subType: item!.subType,
                  scale: scale,
                )
            );
          }
        );
}