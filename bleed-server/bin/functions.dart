import 'package:lemon_math/library.dart';

import 'classes/collider.dart';
import 'common/library.dart';
import 'events/on_collision_between_colliders.dart';

void updateCollisionBetween(List<Collider> colliders) {
  final numberOfColliders = colliders.length;
  final numberOfCollidersMinusOne = numberOfColliders - 1;
  for (var i = 0; i < numberOfCollidersMinusOne; i++) {
    final colliderI = colliders[i];
    if (!colliderI.collidable) continue;
    final colliderIBottom = colliderI.bottom;
    for (var j = i + 1; j < numberOfColliders; j++) {
      final colliderJ = colliders[j];
      if (!colliderJ.collidable) continue;
      if (colliderJ.top > colliderIBottom) break;
      if (colliderJ.left > colliderI.right) continue;
      if (colliderJ.bottom < colliderI.top) continue;
      if ((colliderJ.z - colliderI.z).abs() > tileHeight) continue;
      onCollisionBetweenColliders(colliderJ, colliderI);
    }
  }
}

void resolveCollisionB(Collider a, Collider b) {
  final overlap = a.getOverlap(b);
  if (overlap <= 0) return;
  final xDiff = a.x - b.x;
  final yDiff = a.y - b.y;
  final mag = getHypotenuse(xDiff, yDiff);
  final ratio = 1.0 / mag;
  final xDiffNormalized = xDiff * ratio;
  final yDiffNormalized = yDiff * ratio;
  final targetX = xDiffNormalized * overlap;
  final targetY = yDiffNormalized * overlap;
  a.x += targetX;
  a.y += targetY;
}

void detectAndResolveCollisionsBetweenDifferentLists(
    List<Collider> collidersA,
    List<Collider> collidersB,
) {
  final aLength = collidersA.length;
  final bLength = collidersB.length;
  for (var i = 0; i < aLength; i++) {
    final a = collidersA[i];
    if (!a.collidable) continue;
    for (var j = 0; j < bLength; j++) {
      final b = collidersB[j];
      if (!b.collidable) continue;
      if (a.bottom < b.top) continue;
      if (a.top > b.bottom) continue;
      if (a.right < b.left) continue;
      if (a.left > b.right) continue;
      if ((a.z - b.z).abs() > tileHeight) continue;
      onCollisionBetweenColliders(a, b);
    }
  }
}



