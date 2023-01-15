

class Ease {
  /// @x a number between 0.0 and 1.0
  static double easeOutQuad(double x) => 1 - (1 - x) * (1 - x);
}