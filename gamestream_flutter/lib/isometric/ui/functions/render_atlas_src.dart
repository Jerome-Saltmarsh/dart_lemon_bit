

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/classes/atlas_src.dart';

Widget renderAtlasSrc(AtlasSrc src) =>
  buildCanvasImage(
    srcX: src.srcX,
    srcY: src.srcY,
    srcWidth: src.width,
    srcHeight: src.height,
  );