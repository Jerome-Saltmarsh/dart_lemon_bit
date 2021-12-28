
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/golden_ratio.dart';

import '../../styles.dart';

StyleGuide styleGuide = StyleGuide();

class StyleGuide {
  _Slot slot = _Slot();
}

class _Slot {

  double width = 120;
  double height = 120 * goldenRatioInverse;

  BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: borderRadius4,
      color: Colors.black38,
      border: Border.all(color: Colors.white, width: 1)
  );
}