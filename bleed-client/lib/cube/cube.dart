import 'object.dart';
import 'package:vector_math/vector_math_64.dart';

final _Assets assets = _Assets();

class _Assets {
  final String cube = "assets/cube.obj";
  final String cubeGreen = "assets/cube-green.obj";
}

Object cube({required Vector3 position, required Vector3 rotation}) {
  return Object(
      fileName: assets.cubeGreen,
      position: position,
      rotation: rotation,
      lighting: false,
  );
}