import 'package:lemon_math/src.dart';

List<double> interpolateEaseType({
  required int length,
  required EaseType easeType,
}) => interpolateEaseFunction(
    length: length,
    easeFunction:  getEaseTypeFunction(easeType),
);

