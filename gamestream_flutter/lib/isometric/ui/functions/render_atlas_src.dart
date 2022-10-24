

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/classes/atlas_src.dart';

Widget renderAtlasSrc(AtlasSrc src) =>
  buildAtlasImage(
    srcX: src.srcX,
    srcY: src.srcY,
    srcWidth: src.width,
    srcHeight: src.height,
  );