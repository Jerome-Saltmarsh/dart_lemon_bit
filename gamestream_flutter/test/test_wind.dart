
import 'package:gamestream_flutter/packages/common/src/types/src.dart';
import 'package:test/test.dart';

void main() {
  test('wind', () {
    var value = 0;
    value = Wind.setVelocityX(value, 1);
    value = Wind.setVelocityY(value, 2);
    value = Wind.setVelocityZ(value, 4);
    expect(Wind.getVelocityX(value), 1);
    expect(Wind.getVelocityY(value), 2);

    final actualZ = Wind.getVelocityZ(value);
    expect(actualZ, -5);


  });
}
