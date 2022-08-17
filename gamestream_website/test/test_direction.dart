

import 'dart:math';
import 'package:bleed_common/Direction.dart';
import 'package:test/test.dart';

void main() {
  test('clampAngle', () {
    const piQ = pi * 0.25;
    // assert(clampAngle(-0.25) == pi2 - 0.25);
    // assert(clampAngle(0.25) == 0.25);
    // assert(clampAngle(5.00) == 5.00);
    // assert(clampAngle(10.00) == 10.00 % pi2);
    // print(clampAngle(-104));
    // print(clampAngle(-103));
    // print(clampAngle(-102));
    // print(clampAngle(-101));
    // print(clampAngle(-100));
    // print(clampAngle(-99));

    print(convertAngleToDirection(0));
    print(convertAngleToDirection(piQ));
    print(convertAngleToDirection(piQ * 2));
    print(convertAngleToDirection(piQ * 3));
    print(convertAngleToDirection(piQ * 4));
    print(convertAngleToDirection(piQ * 5));
    print(convertAngleToDirection(piQ * 6));
    print(convertAngleToDirection(piQ * 7));
    print(convertAngleToDirection(piQ * 8));
    print(convertAngleToDirection(piQ * 9));
  });
}
