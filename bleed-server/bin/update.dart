import 'classes.dart';
import 'common.dart';
import 'compile.dart';
import 'constants.dart';
import 'enums.dart';
import 'enums/GameEventType.dart';
import 'jobs.dart';
import 'language.dart';
import 'maths.dart';
import 'settings.dart';
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
    dispatch(GameEventType.Zombie_Target_Acquired, npc.x, npc.y, 0, 0);
    return;
  }
}

void updateBullets() {
  for (int i = 0; i < bullets.length; i++) {
    Bullet bullet = bullets[i];
    bullet.x += bullet.xv;
    bullet.y += bullet.yv;
    if (bulletDistanceTravelled(bullet) > bullet.range) {
      dispatch(GameEventType.Bullet_Hole, bullet.x, bullet.y, 0, 0);
      bullets.removeAt(i);
      i--;
      continue;
    }
  }

  checkBulletCollision(npcs);
  checkBulletCollision(players);
}

void checkBulletCollision(List<Character> characters) {
  for (int i = 0; i < bullets.length; i++) {
    Bullet bullet = bullets[i];
    for (int j = 0; j < characters.length; j++) {
      Character character = characters[j];
      if (character.dead) continue;
      if (character.id == bullet.ownerId) continue;
      double dis = distanceBetween(characters[j], bullet);
      if (dis < characterBulletRadius) {
        bullets.removeAt(i);
        i--;
        changeCharacterHealth(character, -bullet.damage);
        character.xv += bullet.xv * 0.25;
        character.yv += bullet.yv * 0.25;

        if (character.alive) {
          dispatch(GameEventType.Zombie_Hit, character.x, character.y, bullet.xv, bullet.yv);
        } else {
          if(randomBool()){
            dispatch(GameEventType.Zombie_Killed, character.x, character.y, bullet.xv, bullet.yv);
            delayed(() => characters.remove(character), seconds: 3);
          }else{
            characters.removeAt(j);
            j--;
            dispatch(GameEventType.Zombie_killed_Explosion, character.x, character.y, bullet.xv, bullet.yv);
          }
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
      dispatch(GameEventType.Zombie_Strike, npc.x, npc.y, 0, 0);
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
  character.x += character.xv;
  character.y += character.yv;
  character.xv *= velocityFriction;
  character.yv *= velocityFriction;

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
    grenade.zv -= gravity;
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
