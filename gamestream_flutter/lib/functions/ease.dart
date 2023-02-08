

import 'dart:math';

class EaseFunctions {
  static double outQuad(double x) => 1 - (1 - x) * (1 - x);
  static double outCirc(double x) => sqrt(1 - pow(x - 1, 2));
}

typedef EaseFunction = double Function(double i);

enum EaseType {
  Out_Quad(EaseFunctions.outQuad),
  Out_Circ(EaseFunctions.outCirc);

  const EaseType(this.function);

  final EaseFunction function;

  List<double> generate({required int length}) =>
      List.generate(
        length,
            (i) => function(i * (1 / length)),
        growable: false,
      );
}


