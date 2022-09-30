import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';

int getNodeBelowColor(Vector3 vector3) =>
    convertShadeToColor(
      getNodeBelowShade(vector3)
    );

int convertShadeToColor(int shade) =>  colorShades[shade];

int getNodeBelowShade(Vector3 vector3) =>
  gridNodeShade[
    gridNodeIndexVector3NodeBelow(vector3)
  ];

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