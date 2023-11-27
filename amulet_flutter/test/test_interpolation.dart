import 'package:lemon_math/src.dart';
import 'package:test/test.dart';

void main() {
  test('light', () {

    final interpolations = interpolateEaseType(
      length: 6,
      easeType: EaseType.In_Quad,
    );

    print (interpolations);
  });
}
