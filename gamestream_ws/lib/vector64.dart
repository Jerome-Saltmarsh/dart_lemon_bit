

import 'dart:math';

class Vector64 {

  static double getX(int value) =>
      (value & 0x1FFFFF) / 1000.0;

  static double getY(int value) =>
      ((value >> 21) & 0x1FFFFF) / 1000.0;

  static double getZ(int value) =>
      ((value >> 42) & 0x1FFFFF) / 1000.0;

  static int setX(int value, double x) =>
      (value & ~0x1FFFFF) | ((x * 1000).toInt() & 0x1FFFFF);

  static int setY(int value, double y) =>
      (value & ~(0x1FFFFF << 21)) | (((y * 1000).toInt() & 0x1FFFFF) << 21);

  static int setZ(int value, double z) =>
      (value & ~(0x1FFFFF << 42)) | (((z * 1000).toInt() & 0x1FFFFF) << 42);

  static int toInt(double x, double y, double z) {
    int intValue = 0;
    intValue |= ((x * 1000).toInt() & 0x1FFFFF);
    intValue |= (((y * 1000).toInt() & 0x1FFFFF) << 21);
    intValue |= (((z * 1000).toInt() & 0x1FFFFF) << 42);
    return intValue;
  }

  static double getDistanceSquared(int a, int b) {
    final x1 = getX(a);
    final y1 = getY(a);
    final z1 = getZ(a);
    final x2 = getX(b);
    final y2 = getY(b);
    final z2 = getZ(b);

    final dx = x1 - x2;
    final dy = y1 - y2;
    final dz = z1 - z2;

    return (dx * dx) + (dy * dy) + (dz * dz);
  }

  static double getDistance(int a, int b) =>
      sqrt(getDistanceSquared(a, b));

  static int add(int a, int b) {
    final x1 = getX(a);
    final y1 = getY(a);
    final z1 = getZ(a);

    final x2 = getX(b);
    final y2 = getY(b);
    final z2 = getZ(b);

    final sumX = x1 + x2;
    final sumY = y1 + y2;
    final sumZ = z1 + z2;

    return toInt(sumX, sumY, sumZ);
  }

  static int subtract(int a, int b) {
    final x1 = getX(a);
    final y1 = getY(a);
    final z1 = getZ(a);

    final x2 = getX(b);
    final y2 = getY(b);
    final z2 = getZ(b);

    final diffX = x1 - x2;
    final diffY = y1 - y2;
    final diffZ = z1 - z2;

    return toInt(diffX, diffY, diffZ);
  }

  static bool withinRadius(int a, int b, double radius) =>
      getDistanceSquared(a, b) <= (radius * radius);

  static double getSum(int value) =>
      getX(value) + getY(value) + getZ(value);

}