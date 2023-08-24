
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/variables/transparent.dart';

import 'get_max_bottom_from_dst.dart';
import 'get_max_right_from_dst.dart';

Image buildImageFromDst({
  required Uint16List dst,
  required Format format,
}) => Image(
    width: getMaxRightFromDst(dst),
    height: getMaxBottomFromDst(dst),
    numChannels: 4,
    backgroundColor: transparent,
    format: format,
  );