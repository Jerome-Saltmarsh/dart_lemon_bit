
import 'package:bleed_client/maths.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutter_constants.dart';

StyleGuide styleGuide = StyleGuide();

class StyleGuide {
  _Slot slot = _Slot();
}

class _Slot {

  double width = 120;
  double height = 120 * goldenRatioInverse;

  BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: borderRadius4,
      border: Border.all(color: Colors.white, width: 2)
  );
}