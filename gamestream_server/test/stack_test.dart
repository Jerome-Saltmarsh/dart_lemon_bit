


import 'package:gamestream_server/isometric.dart';
import 'package:test/test.dart';

void main() {
  test('stack test', () {
      final positions = [
         IsometricPosition(
             x: 0,
             y: 0,
             z: 0,
         ),
         IsometricPosition(
             x: 2000,
             y: 100,
             z: 0,
         ),
         IsometricPosition(
             x: 0,
             y: 100,
             z: 0,
         ),
      ];

      positions.sort();

      print(positions);

  });
}
