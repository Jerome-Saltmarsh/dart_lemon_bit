import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

int getNodeBelowColor(Vector3 vector3) =>
  colorShades [
    getNodeBelowShade(vector3)
  ];

int getNodeBelowShade(Vector3 vector3) => getNodeBelowV3(vector3).shade;

Node getNodeBelowV3(Vector3 vector3) =>
  getNode(
      ((vector3.z + 1 ) ~/ tileSizeHalf) - 1,
      vector3.indexRow,
      vector3.indexColumn,
  );

Node getNodeV3(Vector3 vector3) =>
    getNode(
      vector3.indexZ,
      vector3.indexRow,
      vector3.indexColumn,
    );