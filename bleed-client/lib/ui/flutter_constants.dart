

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const EdgeInsets padding16 = EdgeInsets.all(16);
const EdgeInsets padding8 = EdgeInsets.all(8);
const BorderRadius borderRadius4 = BorderRadius.all(Radius.circular(4));
const BorderRadius borderRadius8 = BorderRadius.all(Radius.circular(8));

final Border border3 = Border.all(width: 3.0);

final TextDecoration underline = TextDecoration.underline;

final Color black54 = Colors.black54;

_MainAxis mainAxis = _MainAxis();
_CrossAxis crossAxis = _CrossAxis();

class _MainAxis {
  final MainAxisAlignment center = MainAxisAlignment.center;
  final MainAxisAlignment spaceBetween = MainAxisAlignment.spaceBetween;
  final MainAxisAlignment spaceEvenly = MainAxisAlignment.spaceEvenly;
}

class _CrossAxis {
  final CrossAxisAlignment center = CrossAxisAlignment.center;
}