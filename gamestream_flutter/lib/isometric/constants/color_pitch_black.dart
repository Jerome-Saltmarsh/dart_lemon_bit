
import 'package:flutter/cupertino.dart';

const colorPitchBlack = Color.fromRGBO(37, 32, 48, 1.0);

const opacities = <double>[0.0, 0.4, 0.6, 0.7, 0.8, 0.95, 1.0];

final colorShades = opacities
    .map((opacity) => colorPitchBlack.withOpacity(opacity).value)
    .toList(growable: false);
