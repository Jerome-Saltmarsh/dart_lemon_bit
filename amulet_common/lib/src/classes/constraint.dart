
import 'package:lemon_math/src.dart';

class Constraint<T extends num> {
  final T min;
  final T max;
  const Constraint({
    required this.min,
    required this.max,
  });

  double linearInterp(double i) =>
      interpolate(min, max, i)
          .clamp(min, max)
          .toDouble();
}

