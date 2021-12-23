import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

final Camera3D camera3D = Camera3D();

final upAxis = Vector3(0, 1, 0);
final rightAxis = Vector3(1, 0, 0);

class Camera3D {
  Camera3D({
    Vector3? position,
    Vector3? target,
    Vector3? up,
    this.fov = 60.0,
    this.near = 0.1,
    this.far = 1000,
    this.zoom = 1.0,
    this.viewportWidth = 100.0,
    this.viewportHeight = 100.0,
  }) {
    if (position != null) position.copyInto(this.position);
    if (target != null) target.copyInto(this.target);
    if (up != null) up.copyInto(this.up);
  }

  final Vector3 position = Vector3(0.0, 0.0, -10.0);
  Vector3 target = Vector3(0.0, 0.0, 0.0);
  final Vector3 up = Vector3(0.0, 1.0, 0.0);
  double fov;
  double near;
  double far;
  double zoom;
  double viewportWidth;
  double viewportHeight;

  double get aspectRatio => viewportWidth / viewportHeight;

  Matrix4 get lookAtMatrix {
    return makeViewMatrix(position, target, up);
  }

  Quaternion get rotation {
    return Quaternion.euler(
        radians(target.y), radians(target.x), radians(target.z));
  }

  Matrix4 get projectionMatrix {
    final double top = near * math.tan(radians(fov) / 2.0) / zoom;
    final double bottom = -top;
    final double right = top * aspectRatio;
    final double left = -right;
    return makeFrustumMatrix(left, right, bottom, top, near, far);
  }

  void rotateCamera(double xx, double yy, [double sensitivity = 1.0]) {
    final double x = xx * sensitivity / (viewportWidth * 0.5);
    final double y = yy * sensitivity / (viewportHeight * 0.5);
    Quaternion q = Quaternion.axisAngle(upAxis, x);
    Quaternion q2 = Quaternion.axisAngle(rightAxis, y);
    target -= position;
    q.rotate(target);
    q2.rotate(target);
    target += position;
  }

  void trackBall(Vector2 from, Vector2 to, [double sensitivity = 1.0]) {
    // final double x = -(to.x - from.x) * sensitivity / (viewportWidth * 0.5);
    // final double y = (to.y - from.y) * sensitivity / (viewportHeight * 0.5);
    // Vector2 delta = Vector2(x, y);
    // Vector3 moveDirection = Vector3(delta.x, delta.y, 0);
    // final double angle = moveDirection.length;
    // if (angle > 0) {
    //   Vector3 _eye = position - target;
    //   Vector3 eyeDirection = _eye.normalized();
    //   Vector3 upDirection = up.normalized();
    //   Vector3 sidewaysDirection = upDirection.cross(eyeDirection).normalized();
    //   upDirection.scale(delta.y);
    //   sidewaysDirection.scale(delta.x);
    //   moveDirection = upDirection + sidewaysDirection;
    //   Vector3 axis = moveDirection.cross(_eye).normalized();
    //   Quaternion q = Quaternion.axisAngle(axis, angle);
    //   q.rotate(position);
    //   q.rotate(up);
    // }
    final double x = -(to.x - from.x) * sensitivity / (viewportWidth * 0.5);
    final double y = (to.y - from.y) * sensitivity / (viewportHeight * 0.5);
    // Vector2 delta = Vector2(x, y);
    // Vector3 moveDirection = Vector3(delta.x, delta.y, 0);
    // final double angle = moveDirection.length;
    // // if (angle > 0) {
    // Vector3 _eye = position - target;
    // Vector3 eyeDirection = _eye.normalized();
    // Vector3 upDirection = up.normalized();
    // Vector3 sidewaysDirection = upDirection.cross(eyeDirection).normalized();
    // upDirection.scale(delta.y);
    // sidewaysDirection.scale(delta.x);
    // moveDirection = upDirection + sidewaysDirection;
    // Vector3 axis = moveDirection.cross(_eye).normalized();
    Quaternion q = Quaternion.axisAngle(upAxis, x);
    Quaternion q2 = Quaternion.axisAngle(rightAxis, y);
    target -= position;
    q.rotate(target);
    q2.rotate(target);
    target += position;
  }

  void applyRotate(Vector3 axis, double angle){
    target -= position;
    Quaternion q = Quaternion.axisAngle(upAxis, angle);
    q.rotate(target);
    target += position;
  }

  Vector3 get forward {
    return position - target;
  }

  Vector3 get backward {
    return target - position;
  }

  Vector3 copyTarget(){
    return Vector3(target.x, target.y, target.z);
  }

  Vector3 get right {
    Quaternion q = Quaternion.axisAngle(upAxis, math.pi * 0.5);
    Vector3 r = target - position;
    q.rotate(r);
    return r;
  }

  Vector3 get left {
    Quaternion q = Quaternion.axisAngle(upAxis, -math.pi * 0.5);
    Vector3 r = target - position;
    q.rotate(r);
    return r;
  }
}
