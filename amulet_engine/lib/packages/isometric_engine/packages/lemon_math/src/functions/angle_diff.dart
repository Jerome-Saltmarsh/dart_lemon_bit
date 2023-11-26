import 'dart:math';

import '../constants/pi2.dart';

num angleDiff(double angleA, double angleB) {
  final diff = (angleA - angleB).abs();
  if (diff < pi) {
    return diff;
  }
  return pi2 - diff;
}

num radianDiff(double angleA, double angleB) =>
    ((angleA - angleB) + pi) % (pi2) - pi;
