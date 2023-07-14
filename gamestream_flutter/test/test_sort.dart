
import 'package:algorithmic/algorithmic.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_particle.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:test/test.dart';

void main() {

  test('sort-gameobjects', () {
    final gameObjects = <IsometricPosition>[
      IsometricPosition(x: 10, y: 10, z: 10),
      IsometricPosition(x: 100, y: 100, z: 10),
      IsometricPosition(x: 10, y: 10, z: 1000),
    ];
    quickSortHaore(gameObjects);
    print(gameObjects);
  });

  test('sort-particles', () {
    final particles = <IsometricParticle>[
      IsometricParticle(x: 10, y: 10, z: 1000, active: false),
      IsometricParticle(x: 10, y: 10, z: 10, active: true),
      IsometricParticle(x: 100, y: 100, z: 10, active: true),
      IsometricParticle(x: 10, y: 10, z: 1000, active: true),
      IsometricParticle(x: 5, y: 10, z: 5, active: false),
    ];
    particles.sort(IsometricParticle.compare);
    print(particles);
  });
}
