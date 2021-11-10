import 'dart:async';

import 'classes/Game.dart';
import 'classes.dart';
import 'language.dart';
import 'maths.dart';
import 'server.dart';
import 'state.dart';

const _minusOne = -1;
const _one = 1;

void initUpdateLoop() {
  // @on init jobs
  Future.delayed(Duration(seconds: 3), (){
    periodic(fixedUpdate, ms: 1000 ~/ 30);
    periodic(jobNpcWander, seconds: 4);
    periodic(jobRemoveDisconnectedPlayers, seconds: 5);
    periodic(updateNpcTargets, ms: 500);
  });
}

void updateNpcTargets(Timer timer) {
  world.town.updateZombieTargets();
  world.town.updateInteractableNpcTargets();
  world.cave.updateZombieTargets();
  world.cave.updateInteractableNpcTargets();
}

void jobRemoveDisconnectedPlayers(Timer timer) {
  world.cave.jobRemoveDisconnectedPlayers();
  world.town.jobRemoveDisconnectedPlayers();
}

void jobNpcWander(Timer timer) {
  world.cave.jobNpcWander();
  world.town.jobNpcWander();
}

void fixedUpdate(Timer timer) {
  frame++;
  updateGames();
}

void updateGames() {
  world.cave.updateAndCompile();
  world.town.updateAndCompile();
}

int compareGameObjectsX(GameObject a, GameObject b) {
  if (a.x < b.x) {
    return _minusOne;
  }
  return _one;
}

int compareGameObjectsY(GameObject a, GameObject b) {
  if (a.y < b.y) {
    return _minusOne;
  }
  return _one;
}

void updateCollisionBetween(List<GameObject> gameObjects) {
  for (int i = 0; i < gameObjects.length - 1; i++) {
    if (!gameObjects[i].collidable) continue;
    for (int j = i + 1; j < gameObjects.length; j++) {
      if (!gameObjects[j].collidable) continue;
      if (gameObjects[j].top > gameObjects[i].bottom) break;
      if (gameObjects[j].left > gameObjects[i].right) continue;
      if (gameObjects[j].bottom < gameObjects[i].top) continue;
      resolveCollisionA(gameObjects[i], gameObjects[j]);
    }
  }
}

typedef void CollisionResolver(GameObject a, GameObject b);

void resolveCollisionA(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if (overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;

  if (xDiff == 0 && yDiff == 0) {
    a.x -= 5;
    b.y += 5;
    xDiff = 10;
  }

  double halfOverlap = overlap * 0.5;
  double mag = magnitude(xDiff, yDiff);
  double ratio = 1.0 / mag;
  double xDiffNormalized = xDiff * ratio;
  double yDiffNormalized = yDiff * ratio;
  double targetX = xDiffNormalized * halfOverlap;
  double targetY = yDiffNormalized * halfOverlap;
  a.x += targetX;
  a.y += targetY;
  b.x -= targetX;
  b.y -= targetY;
}

void resolveCollisionB(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if (overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;
  double mag = magnitude(xDiff, yDiff);
  double ratio = 1.0 / mag;
  double xDiffNormalized = xDiff * ratio;
  double yDiffNormalized = yDiff * ratio;
  double targetX = xDiffNormalized * overlap;
  double targetY = yDiffNormalized * overlap;
  a.x += targetX;
  a.y += targetY;
}

double collisionOverlap(GameObject a, GameObject b) {
  return a.radius + b.radius - distanceBetween(a, b);
}

void resolveCollisionBetween(List<GameObject> gameObjectsA,
    List<GameObject> gameObjectsB, CollisionResolver resolve) {
  int minJ = 0;
  for (int i = 0; i < gameObjectsA.length; i++) {
    if (!gameObjectsA[i].collidable) continue;
    for (int j = minJ; j < gameObjectsB.length; j++) {
      if (!gameObjectsB[j].collidable) continue;
      if (gameObjectsA[i].bottom < gameObjectsB[j].top) {
        minJ++;
        break;
      }
      if (gameObjectsA[i].top > gameObjectsB[j].bottom) continue;
      if (gameObjectsA[i].right < gameObjectsB[j].left) continue;
      if (gameObjectsA[i].left > gameObjectsB[j].right) continue;
      resolve(gameObjectsA[i], gameObjectsB[j]);
    }
  }
}
