import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/nodes/getters/get_node_shade.dart';

int convertShadeToColor(int shade) =>  colorShades[shade];

int getRenderShade(Vector3 vector3) =>
  getNodeBelowShade(vector3);

int getRenderColor(Vector3 vector3) =>
    convertShadeToColor(
        getNodeBelowShade(vector3)
    );

int getNodeBelowShade(Vector3 vector3) =>
  getNodeShade(vector3.indexZ - 1, vector3.indexRow, vector3.indexColumn);
