import 'ease_type.dart';
import 'get_ease_function.dart';

List<double> interpolateEase({required int length, required EaseType easeType}) {
  final easeFunction = getEaseTypeFunction(easeType);
  return List.generate(
    length,
        (i) => easeFunction(i * (1 / length)),
    growable: false,
  );
}
