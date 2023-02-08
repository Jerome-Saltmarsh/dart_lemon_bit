

import 'dart:math';

class Ease {

  static double outQuad(double x) => 1 - (1 - x) * (1 - x);
  static double outCirc(double x) => sqrt(1 - pow(x - 1, 2));

  static List<double> generateCurve({
    required int length,
    required EaseFunction function,
  }) =>
      List.generate(
        length,
        (i) => function(i * (1 / length)),
        growable: false,
      );

  static EaseFunction getEaseFunction(EaseType easeType) =>
      const <EaseType, EaseFunction> {
        EaseType.Out_Quad: outQuad,
        EaseType.Out_Circ: outCirc,
      }[easeType]!;
}

typedef EaseFunction = double Function(double i);

enum EaseType {
  Out_Quad,
  Out_Circ,
}


