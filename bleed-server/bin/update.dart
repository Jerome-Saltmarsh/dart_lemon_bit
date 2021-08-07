import 'dart:math';

import 'classes.dart';
import 'classes/Particle.dart';
import 'common.dart';
import 'compile.dart';
import 'constants.dart';
import 'enums.dart';
import 'jobs.dart';
import 'language.dart';
import 'maths.dart';
import 'settings.dart';
import 'spawn.dart';
import 'state.dart';
import 'utils.dart';

void initUpdateLoop() {
  periodic(fixedUpdate, ms: 1000 ~/ 30);
  periodic(jobNpcWander, seconds: 3);
  periodic(jobRemoveDisconnectedPlayers, seconds: 5);
  periodic(updateNpcTargets, ms: 500);
}

void updateNpcTargets() {
  for (Npc npc in npcs) {
    if (npc.targetSet) continue;
    updateNpcTarget(npc);
  }
}

void updateNpcTarget(Npc npc) {
  for (Character player in players) {
    if (player.dead) continue;
    if (distanceBetween(npc, player) > zombieViewRange) continue;
    npc.targetId = player.id;
    dispatch(GameEventType.Zombie_Target_Acquired, npc.x, npc.y);
    return;
  }
}

void updateBullets() {
  for (int i = 0; i < bullets.length; i++) {
    Bullet bullet = bullets[i];
    bullet.x += bullet.xVel;
    bullet.y += bullet.yVel;
    if (bulletDistanceTravelled(bullet) > bullet.range) {
      dispatch(GameEventType.Bullet_Hole, bullet.x, bullet.y);
      bullets.removeAt(i);
      i--;
      continue;
    }
  }

  checkBulletCollision(npcs);
  checkBulletCollision(players);
}

void checkBulletCollision(List<Character> list) {
  for (int i = 0; i < bullets.length; i++) {
    Bullet bullet = bullets[i];
    for (int j = 0; j < list.length; j++) {
      Character character = list[j];
      if (character.dead) continue;
      if (character.id == bullet.ownerId) continue;
      double dis = distanceBetween(list[j], bullet);
      if (dis < characterBulletRadius) {
        bullets.removeAt(i);
        i--;
        changeCharacterHealth(character, -bullet.damage);
        character.xVel += bullet.xVel * 0.25;
        character.yVel += bullet.yVel * 0.25;

        if (character.alive) {
          gameEvents.add(
              GameEvent(character.x, character.y, GameEventType.Zombie_Hit));
        } else {
          gameEvents.add(
              GameEvent(character.x, character.y, GameEventType.Zombie_Killed));
        }

        for (int i = 0; i < randomBetween(2, 5).toInt(); i++) {
          blood.add(Blood(
              character.x,
              character.y,
              bullet.xVel * randomBetween(0, 0.5) + giveOrTake(pi),
              bullet.yVel * randomBetween(0, 0.5) + giveOrTake(pi)));
        }

        break;
      }
    }
  }
}

void updateNpc(Npc npc) {
  if (npc.dead) return;

  if (npc.state == CharacterState.Striking) {
    if (npc.shotCoolDown-- > 0) return;
    setCharacterStateIdle(npc);
  }

  if (npc.targetSet) {
    Character? target = npcTarget(npc);
    if (target == null) {
      npc.clearTarget();
      npc.idle();
      return;
    }

    characterFaceObject(npc, target);
    double targetDistance = objectDistanceFrom(npc, target.x, target.y);

    if (targetDistance > settingsZombieStrikeRange) {
      npc.walk();
    } else {
      setCharacterState(npc, CharacterState.Striking);
      changeCharacterHealth(target, -0.1);
      dispatch(GameEventType.Zombie_Strike, npc.x, npc.y);
      blood.add(Blood(target.x, target.y + 5, giveOrTake(5), giveOrTake(5)));
    }
    return;
  }

  if (npc.destinationSet) {
    if (arrivedAtDestination(npc)) {
      npc.clearDestination();
      npc.idle();
    } else {
      faceDestination(npc);
      npc.walk();
    }
    return;
  }

  npc.idle();
}

void updateCharacter(Character character) {
  character.x += character.xVel;
  character.y += character.yVel;
  character.xVel *= velocityFriction;
  character.yVel *= velocityFriction;

  switch (character.state) {
    case CharacterState.Aiming:
      if (character.accuracy > 0.05) {
        character.accuracy -= 0.005;
      }
      break;
    case CharacterState.Firing:
      character.shotCoolDown--;
      if (character.shotCoolDown <= 0) {
        setCharacterState(character, CharacterState.Aiming);
      }
      break;
    case CharacterState.Dead:
      if (frame % 2 == 0) {
        double speed = randomBetween(0.5, 1.25);
        spawnBlood(character, randomRadion(), speed);
      }
      break;
    case CharacterState.Walking:
      switch (character.direction) {
        case Direction.Up:
          character.y -= character.speed;
          break;
        case Direction.UpRight:
          character.x += velX(piQuarter, character.speed);
          character.y += velY(piQuarter, character.speed);
          break;
        case Direction.Right:
          character.x += character.speed;
          break;
        case Direction.DownRight:
          character.x += velX(piQuarter, character.speed);
          character.y -= velY(piQuarter, character.speed);
          break;
        case Direction.Down:
          character.y += character.speed;
          break;
        case Direction.DownLeft:
          character.x -= velX(piQuarter, character.speed);
          character.y -= velY(piQuarter, character.speed);
          break;
        case Direction.Left:
          character.x -= character.speed;
          break;
        case Direction.UpLeft:
          character.x -= velX(piQuarter, character.speed);
          character.y += velY(piQuarter, character.speed);
          break;
      }
      break;
    case CharacterState.Running:
      double runRatio = character.speed * (1.0 + goldenRatioInverse);
      switch (character.direction) {
        case Direction.Up:
          character.y -= runRatio;
          break;
        case Direction.UpRight:
          character.x += velX(piQuarter, runRatio);
          character.y += velY(piQuarter, runRatio);
          break;
        case Direction.Right:
          character.x += runRatio;
          break;
        case Direction.DownRight:
          character.x += velX(piQuarter, runRatio);
          character.y -= velY(piQuarter, runRatio);
          break;
        case Direction.Down:
          character.y += runRatio;
          break;
        case Direction.DownLeft:
          character.x -= velX(piQuarter, runRatio);
          character.y -= velY(piQuarter, runRatio);
          break;
        case Direction.Left:
          character.x -= runRatio;
          break;
        case Direction.UpLeft:
          character.x -= velX(piQuarter, runRatio);
          character.y += velY(piQuarter, runRatio);
          break;
      }
      break;
  }
}

void updateCharacters() {
  players.forEach(updateCharacter);
  npcs.forEach(updateCharacter);

  for (Player player in players) {
    if (frame - player.lastEventFrame > 5 && player.walking) {
      setCharacterStateIdle(player);
      print("no event from player. Idling; ${player.lastEventFrame}");
    }
  }
}

void fixedUpdate() {
  frame++;
  DateTime now = DateTime.now();
  frameDuration = now.difference(frameTime);
  if (frameDuration.inMilliseconds > 0) {
    fps = 1000 ~/ frameDuration.inMilliseconds;
  }
  frameTime = now;
  updateCharacters();
  updateCollisions();
  updateBullets();
  updateBullets(); // called twice to fix collision detection
  updateNpcs();
  updateBlood();
  updateParticles();
  updateGameEvents();
  updateGrenades();

  compileState();

  if (fps < 20) {
    // print("Warning FPS Drop: $fps");
  }
}


void updateGrenades() {
  for (Grenade grenade in grenades) {
    applyMovement(grenade);
    applyFriction(grenade, settingsGrenadeFriction);
    double gravity = 0.06;
    grenade.zVel -= gravity;
    if(grenade.z < 0){
      grenade.z = 0;
    }
  }
}

void updateGameEvents() {
  for (int i = 0; i < gameEvents.length; i++) {
    if (gameEvents[i].frameDuration-- > 0) continue;
    gameEvents.removeAt(i);
    i--;
  }
}

void updateBlood() {
  for (int i = 0; i < blood.length; i++) {
    if (blood[i].lifeTime-- < 0) {
      blood.removeAt(i);
      i--;
      continue;
    }
    blood[i].x += blood[i].xVel;
    blood[i].y += blood[i].yVel;

    blood[i].xVel *= 0.85;
    blood[i].yVel *= 0.85;
  }
}

void updateParticles() {
  for (int i = 0; i < particles.length; i++) {
    Particle particle = particles[i];
    if (particle.lifeTime-- < 0) {
      particles.removeAt(i);
      i--;
      continue;
    }

    double gravity = 0.04;
    double bounceFriction = 0.99;
    double bounceHeightFriction = 0.3;
    double airFriction = 0.98;
    double rotationFriction = 0.93;
    double floorFriction = 0.9;

    bool airBorn = particle.height > 0.01;
    particle.height = particle.height + particle.heightVelocity;
    if(particle.height <= 0.0001){
      particle.height = 0;
    }
    bool bounce = airBorn && particle.height <= 0;

    if (bounce) {
      particle.heightVelocity = -particle.heightVelocity * bounceHeightFriction;
      particle.xVel = particle.xVel * bounceFriction;
      particle.yVel = particle.yVel * bounceFriction;
      particle.rotationSpeed *= rotationFriction;
    }else if(airBorn){
      particle.heightVelocity -= gravity;
      particle.xVel *= airFriction;
      particle.yVel *= airFriction;
    }else{ // on floor
      particle.xVel *= floorFriction;
      particle.yVel *= floorFriction;
      particle.rotationSpeed *= rotationFriction;
    }
    particle.x += particle.xVel;
    particle.y += particle.yVel;
    particle.rotation += particle.rotationSpeed;

    if (particle.type == ParticleType.Head &&
        particle.lifeTime & 2 == 0) {
      blood.add(Blood(particle.x, particle.y, 0.0, 0.0));
    }

    if (particle.type == ParticleType.Arm &&
        particle.lifeTime & 2 == 0) {
      blood.add(Blood(particle.x, particle.y, 0.0, 0.0));
    }
    if (particle.type == ParticleType.Organ &&
        particle.lifeTime & 2 == 0) {
      blood.add(Blood(particle.x, particle.y, 0.0, 0.0));
    }
  }
}

void updateNpcs() {
  npcs.forEach(updateNpc);
}

int compareCharacters(GameObject a, GameObject b) {
  if (a.x < b.x) {
    return -1;
  }
  return 1;
}

void updateCollisionBetween(List<Character> characters) {
  for (int i = 0; i < characters.length - 1; i++) {
    if (characters[i].dead) continue;
    for (int j = i + 1; j < characters.length; j++) {
      resolveCollision(characters[i], characters[j]);
    }
  }
}

void resolveCollision(Character a, Character b) {
  if (a.dead) return;
  if (b.dead) return;
  double xDiff = a.x - b.x;
  if (abs(xDiff) > characterRadius2) return;
  double yDiff = a.y - b.y;
  if (abs(yDiff) > characterRadius2) return;
  double distance = distanceBetween(a, b);
  if (distance >= characterRadius2) return;
  double overlap = characterRadius2 - distance;
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

void updateCollisions() {
  npcs.sort(compareCharacters);
  players.sort(compareCharacters);

  updateCollisionBetween(npcs);
  updateCollisionBetween(players);

  for (int i = 0; i < npcs.length; i++) {
    for (int j = 0; j < players.length; j++) {
      resolveCollision(npcs[i], players[j]);
    }
  }
}
