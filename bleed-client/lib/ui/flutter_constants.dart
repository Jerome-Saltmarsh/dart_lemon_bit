

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const EdgeInsets padding16 = EdgeInsets.all(16);
const EdgeInsets padding8 = EdgeInsets.all(8);
const EdgeInsets padding4 = EdgeInsets.all(4);
const BorderRadius borderRadius4 = BorderRadius.all(radius4);
const BorderRadius borderRadius8 = BorderRadius.all(radius8);
const BorderRadius borderRadius16 = BorderRadius.all(radius16);
const BorderRadius borderRadius32 = BorderRadius.all(radius32);

const BorderRadius borderRadiusBottomRight8 = BorderRadius.only(bottomRight: radius8);

const Radius radius4 = Radius.circular(4);
const Radius radius8 = Radius.circular(8);
const Radius radius16 = Radius.circular(16);
const Radius radius32 = Radius.circular(32);

final Border border3 = Border.all(width: 3.0);

final TextDecoration underline = TextDecoration.underline;

final Color black45 = Colors.black45;
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
  final CrossAxisAlignment start = CrossAxisAlignment.start;
  final CrossAxisAlignment end = CrossAxisAlignment.end;
}