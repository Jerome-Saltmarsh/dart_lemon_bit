
import 'package:bleed_common/src.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';

class MMOItemImage extends StatelessWidget {
  final double size;
  final MMOItem item;

  MMOItemImage({required this.item, required this.size});

  @override
  Widget build(BuildContext context) =>
      ItemImage(size: size, type: item.type, subType: item.subType);
}