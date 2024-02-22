import 'package:flutter/material.dart';

import 'amulet_item_image.dart';


class AmuletImageSrc extends StatelessWidget {

  final List<double> src;

  const AmuletImageSrc({super.key, required this.src});

  @override
  Widget build(BuildContext context) => AmuletImage(
    srcX: src[0],
    srcY: src[1],
    width: src[2],
    height: src[3],
  );
}
