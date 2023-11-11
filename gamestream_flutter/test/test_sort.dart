
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:lemon_math/src.dart';
import 'package:test/test.dart';

void main() {

  test('sort-gameobjects', () {
    final gameObjects = <Position>[
      Position(x: 10, y: 10, z: 10),
      Position(x: 100, y: 100, z: 10),
      Position(x: 10, y: 10, z: 1000),
    ];
    print(gameObjects);
  });

  test('sort-particles', () {
    final particles = <Particle>[
      Particle(x: 10, y: 10, z: 1000),
      Particle(x: 10, y: 10, z: 10),
      Particle(x: 100, y: 100, z: 10),
      Particle(x: 10, y: 10, z: 1000),
      Particle(x: 5, y: 10, z: 5),
    ];
    particles.sort(Particle.compare);
    print(particles);
  });



  test('plain-index', () {
    final rows = 3;
    final columns = 5;
    final height = 6;

    var index = 8;

    final row = clamp(index - (height + columns), 0, rows - 1);
    final column = clamp(index - height + 1, 0, columns - 1);
    final z = clamp(index, 0, height - 1);
    print('{row: $row, column: $column, z: $z, index: $index');

    expect(row, 0);
    expect(column, 3);
    expect(z, 5);
  });

  test('plain-index-12', () {
    final rows = 3;
    final columns = 5;
    final height = 6;

    var index = 12;

    final row = clamp(index - (height + columns), 0, rows - 1);
    final column = clamp(index - height + 1, 0, columns - 1);
    final z = clamp(index, 0, height - 1);
    print('{row: $row, column: $column, z: $z, index: $index');

    expect(row, 1);
    expect(column, 4);
    expect(z, 5);
  });

  test('plain-index-3', () {
    final rows = 3;
    final columns = 5;
    final height = 6;

    var index = 3;

    final row = clamp(index - (height + columns), 0, rows - 1);
    final column = clamp(index - height + 1, 0, columns - 1);
    final z = clamp(index, 0, height - 1);
    print('{row: $row, column: $column, z: $z, index: $index');

    expect(row, 0);
    expect(column, 0);
    expect(z, 3);
  });
}
