import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/attack_state.dart';
import '../common/library.dart';
import '../common/maths.dart';
import '../common/node_size.dart';
import '../common/teams.dart';
import '../engine.dart';
import '../functions/withinRadius.dart';
import '../io/write_scene_to_file.dart';
import '../maths.dart';
import '../maths/get_distance_between_v3.dart';
import '../physics.dart';
import 'ai.dart';
import 'character.dart';
import 'collider.dart';
import 'components.dart';
import 'gameobject.dart';
import 'npc.dart';
import 'player.dart';
import 'position3.dart';
import 'projectile.dart';
import 'rat.dart';
import 'scene.dart';
import 'weapon.dart';
import 'zombie.dart';

abstract class Game {
  var frame = 0;
  final Scene scene;
  final players = <Player>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];

  List<GameObject> get gameObjects => scene.gameObjects;

  /// In seconds
  void customInitPlayer(Player player) {}
  /// safe to override
  void customPlayerWrite(Player player){ }
  /// safe to override
  void customUpdatePlayer(Player player){ }
  /// safe to override
  void customDownloadScene(Player player){ }
  /// safe to override
  void customUpdate();
  /// safe to override
  void customOnPlayerDisconnected(Player player) { }
  /// safe to override
  void customOnGameObjectDeactivated(GameObject gameObject){ }
  /// safe to override
  void customOnCharacterSpawned(Character character) { }
  /// safe to override
  void customOnCharacterKilled(Character target, dynamic src) { }
  /// safe to override
  void customOnCharacterDamageApplied(Character target, dynamic src, int amount) { }
  /// safe to overridable
  void customOnPlayerRevived(Player player) { }
  /// safe to overridable
  void customOnGameStarted() { }
  /// safe to overridable
  void customOnNpcObjectivesCompleted(Character npc) { }
  /// safe to overridable
  void customOnPlayerLevelGained(Player player) { }
  /// safe to overridable
  void customOnPlayerAddCardToDeck(Player player, CardType cardType) { }
  /// safe to override
  void customOnCollisionBetweenColliders(Collider a, Collider b) { }
  /// safe to override
  void customOnCollisionBetweenPlayerAndOther(Player player, Collider collider) { }
  /// safe to override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) { }
  /// safe to override
  void customOnAIRespawned(AI ai){  }
  /// safe to override
  void customOnPlayerRequestPurchaseWeapon(Player player, int type){ }
  /// safe to override
  void customOnPlayerWeaponRoundsExhausted(Player player, Weapon weapon){
    playerSetWeaponUnarmed(player);
  }
  /// safe to override
  void customOnPlayerWeaponChanged(Player player, Weapon newWeapon, Weapon previousWeapon){ }
  /// once the player has finished striking then reequip the weapon
  void customOnPlayerWeaponReady(Player player) {  }
  /// PROPERTIES

  /// Safe to override
  double get minAimTargetCursorDistance => 35;

  bool get customPropMapVisible => false;
  int get gameType;


  /// CONSTRUCTOR
  Game(this.scene) {
    engine.onGameCreated(this); /// TODO Illegal external scope reference
  }

  /// QUERIES

  GameObject? findGameObjectByType(int type){
    for (final gameObject in gameObjects){
       if (gameObject.type == type) return gameObject;
    }
    return null;
  }

  /// ACTIONS

  void moveV3ToNodeIndex(Position3 vector3, int nodeIndex){
    vector3.x = scene.convertNodeIndexToXPosition(nodeIndex);
    vector3.y = scene.convertNodeIndexToYPosition(nodeIndex);
    vector3.z = scene.convertNodeIndexToZPosition(nodeIndex);
  }

  void move(Position3 value, double angle, double distance){
    value.x += getAdjacent(angle, distance);
    value.y += getOpposite(angle, distance);
  }

  void onPlayerUpdateRequestedReceived({
    required Player player,
    required int direction,
    required int cursorAction,
    /// Right Click
    required bool perform2,
    /// Space Bar
    required bool perform3,
    required double mouseX,
    required double mouseY,
    required double screenLeft,
    required double screenTop,
    required double screenRight,
    required double screenBottom,
    required bool runToMouse,
  }) {
    player.framesSinceClientRequest = 0;
    player.screenLeft = screenLeft;
    player.screenTop = screenTop;
    player.screenRight = screenRight;
    player.screenBottom = screenBottom;
    player.mouse.x = mouseX;
    player.mouse.y = mouseY;

    if (cursorAction == CursorAction.Set_Target) {
      var closestDistance = 9999.0;
      Character? closestCharacter;
      for (final character in characters){
         if (character.deadOrDying) continue;
         if (onSameTeam(player, character)) continue;
         final distance = getDistanceV3(player.mouseGridX, player.mouseGridY, player.z, character.x, character.y, character.z);
         if (distance > closestDistance) continue;
         closestDistance = distance;
         closestCharacter = character;
      }

      if (closestCharacter != null && closestDistance < 50) {
        if (direction == Direction.None){
          setCharacterTarget(player, closestCharacter);
        }
        if (player.withinAttackRange(closestCharacter)) {
          player.lookAt(closestCharacter);
          playerUseWeapon(player, autoAim: false);
          player.setCharacterStateIdle();
          clearCharacterTarget(player);
        }
      } else {
        if (direction == Direction.None) {
          player.runToMouse();
        } else {
          playerUseWeapon(player, autoAim: false);
        }
      }
    }

    if (cursorAction == CursorAction.None){
      playerRunInDirection(player, direction);
    }

    if (cursorAction == CursorAction.Stationary_Attack_Cursor){
      playerUseWeapon(player, autoAim: false);
    }

    if (cursorAction == CursorAction.Stationary_Attack_Auto){
      playerUseWeapon(player, autoAim: true);
    }

    if (player.deadOrBusy) return;

    playerRunInDirection(player, direction);
    playerUpdateAimTarget(player);

    final weapon = player.weapon;

    if (weapon.durationRemaining > 0) return;
    weapon.state = AttackState.Aiming;
    player.lookRadian = player.mouseAngle;
  }

  void playerSetWeaponUnarmed(Player player) {
    playerSetWeapon(player, buildWeaponUnarmed());
  }

  void playerSetWeapon(Player player, Weapon weapon){
    if (player.weapon == weapon) return;
    player.weapon = weapon;
    player.writePlayerWeaponType();
    player.writePlayerWeaponRounds();
    player.writePlayerWeaponCapacity();
    player.writePlayerEventItemEquipped(player.weapon.type);
  }

  void changeGame(Player player, Game to){
    if (this == to) return;
    removePlayer(player);
    for (final character in characters) {
      if (character.target != this) continue;
      clearCharacterTarget(character);
    }
    to.players.add(player);
    to.characters.add(player);
    player.sceneDownloaded = false;
    player.game = to;
    player.game.clearCharacterTarget(player);
  }

  void playerUpdateAimTarget(Player player){
    player.aimTarget = getClosestCollider(
      player.mouseGridX,
      player.mouseGridY,
      player,
      minDistance: minAimTargetCursorDistance,
    );
  }

  void playerReleaseWeaponCharge(Player player, Weapon weapon){
    if (weapon.charge <= 0) return;

    final maxCharge = 30;
    double power = weapon.charge >= maxCharge ? 1.0 : weapon.charge / maxCharge;
    weapon.charge = 0;
    dispatchV3(GameEventType.Release_Bow, player);
    spawnProjectileArrow(
      src: player,
      angle: player.lookRadian,
      damage: weapon.damage,
      range: weapon.range * power,
    );
  }

  void playerRunInDirection(Player player, int direction) {
    if (direction == Direction.None && !player.targetSet) {
      player.setCharacterStateIdle();
      return;
    }

    if (player.targetSet) {
      if (direction == Direction.None) {
        return;
      }
      clearCharacterTarget(player);
      player.setCharacterStateIdle();
      return;
    } else if (direction == Direction.None) {
      clearCharacterTarget(player);
      player.setCharacterStateIdle();
      return;
    }
    player.faceDirection = direction;
    setCharacterStateRunning(player);
    clearCharacterTarget(player);

    if (player.interactingWithNpc){
      return player.endInteraction();
    }
  }

  void playerUseWeapon(Player player, {bool autoAim = false}) {
    if (player.deadBusyOrPerforming) return;

    final weapon = player.weapon;

    if (weapon.capacity > 0){
      if (weapon.rounds == 0) return;
      weapon.rounds--;
      player.writePlayerWeaponRounds();
    }

    switch (weapon.type) {
      case AttackType.Unarmed:
        return playerAttackMelee(
          player: player,
          attackType: AttackType.Unarmed,
          distance: weapon.range,
          attackRadius: 35,
          damage: weapon.damage,
          duration: weapon.duration,
        );
      case AttackType.Blade:
        return playerAttackMelee(
          player: player,
          attackType: weapon.type,
          distance: weapon.range,
          attackRadius: 35, /// TODO read value from weapon
          damage: weapon.damage,
          duration: weapon.duration,
        );
      case AttackType.Crossbow:
        return spawnProjectileArrow(
            src: player,
            angle: player.lookRadian,
            damage: weapon.damage,
            range: weapon.range,
        );
      case AttackType.Teleport:
        return playerTeleportToMouse(player);
      case AttackType.Handgun:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.lookRadian,
        );
      case AttackType.Shotgun:
        return characterFireShotgun(player, player.lookRadian);
      case AttackType.Assault_Rifle:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.lookRadian,
        );
      case AttackType.Rifle:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.lookRadian,
        );
      case AttackType.Fireball:
        characterSpawnProjectileFireball(
            player,
            angle: player.lookRadian,
        );
        break;
      case AttackType.Revolver:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.lookRadian,
        );
      case AttackType.Crowbar:
        return playerAttackMelee(
          player: player,
          attackType: weapon.type,
          distance: weapon.range,
          attackRadius: 35, /// TODO read value from weapon
          damage: weapon.damage,
          duration: weapon.duration,
        );
      case AttackType.Bow:
        weapon.durationRemaining = weapon.duration;
        spawnProjectileArrow(
            src: player,
            damage: weapon.damage,
            range: weapon.range,
            angle: player.lookRadian,
        );
        break;
      case AttackType.Staff:
        weapon.durationRemaining = weapon.duration;
        if (autoAim) {
          playerAutoAim(player, weapon.range);
        }
        spawnProjectileOrb(src: player, damage: 2);
        // playerAttackMelee(
        //   player: player,
        //   attackType: weapon.type,
        //   distance: weapon.range,
        //   attackRadius: 35, /// TODO read value from weapon
        //   damage: weapon.damage,
        //   duration: weapon.duration,
        // );
        break;
    }
  }

  void playerTeleportToMouse(Player player){
    positionToPlayerMouse(player, player);
  }

  void positionToPlayerMouse(Position position, Player player){
    position.x = player.mouseGridX;
    position.y = player.mouseGridY;
  }

  void playerAutoAim(Player player, double minDistance) {
    if (player.deadOrBusy) return;
    var closestCharacterDistance = minDistance * 1.5;
    Character? closestCharacter = null;
    for (final character in characters) {
      if (character.deadOrDying) continue;
      if (onSameTeam(player, character)) continue;
      final distance = getDistanceBetweenV3(player, character);
      if (distance > closestCharacterDistance) continue;
      closestCharacter = character;
      closestCharacterDistance = distance;
    }
    if (closestCharacter != null) {
      player.lookAt(closestCharacter);
    }
  }

  void playerAttackMelee({
    required Player player,
    required int attackType,
    required double distance,
    required double attackRadius,
    required int damage,
    required int duration,
  }) {

    if (player.autoAim) {
      playerAutoAim(player, distance);
    }

    final angle = player.lookRadian;

    final performX = player.x + getAdjacent(angle, distance);
    final performY = player.y + getOpposite(angle, distance);
    final performZ = player.z;

    player.performX = performX;
    player.performY = performY;
    player.performZ = performZ;
    player.weapon.durationRemaining = player.weapon.duration;

    /// TODO name arguments
    dispatchAttackPerformed(
        attackType,
        performX,
        performY,
        performZ,
        angle,
    );

    player.applyForce(
      force: 2.5,
      angle: angle,
    );

    if (player.idling) {
      // playerFaceMouse(player);
    }

    var attackHit = false;

    for (final character in characters) {
      if (!character.collidable) continue;
      if (onSameTeam(player, character)) continue;
      if (character.distanceFromXYZ(
        performX,
        performY,
        performZ,
      ) > attackRadius) continue;
      applyHit(src: player, target: character, damage: damage);
      attackHit = true;
       player.applyForce(
           force: 7.5,
           angle: getAngleBetween(player.x, player.y, character.x, character.y),
       );
    }

    for (final gameObject in gameObjects) {
      if (gameObject.distanceFromXYZ(
        performX,
        performY,
        performZ,
      ) >
          attackRadius) continue;

      if (gameObject is Velocity == false) continue;
      (gameObject as Velocity).applyForce(
        force: 5,
        angle: radiansV2(player, gameObject),
      );

      attackHit = true;
    }

    if (!scene.getNodeInBoundsXYZ(performX, performY, performZ)) return;
    final nodeIndex = scene.getNodeIndexXYZ(performX, performY, performZ);
    final nodeType = scene.nodeTypes[nodeIndex];

    player.applyForce(
      force: 4.5,
      angle: angle + pi,
    );

    attackHit = true;
    for (final player in players) {
      player.writeGameEvent(
          type: GameEventType.Node_Struck,
          x: performX,
          y: performY,
          z: performZ,
          angle: angle,
      );
      player.writeByte(nodeType);
    }

    if (NodeType.isDestroyable(nodeType)) {
      setNode(
          nodeIndex: nodeIndex,
          nodeType: NodeType.Empty,
          nodeOrientation: NodeOrientation.None,
      );
      attackHit = true;
    }

    if (!attackHit){
      for (final player in players) {
        player.writeGameEvent(
          type: GameEventType.Attack_Missed,
          x: performX,
          y: performY,
          z: performZ,
          angle: angle,
        );
        player.writeByte(attackType);
      }
    }
  }

  void characterFireWeapon({
    required Character character,
    required Weapon weapon,
    required double angle,
  }){
    if (weapon.durationRemaining > 0) return;
    weapon.durationRemaining = weapon.duration;
    weapon.state = AttackState.Firing;
    character.applyForce(
      force: 2.0,
      angle: angle + pi,
    );

    spawnProjectile(
      src: character,
      accuracy: 0,
      angle: angle,
      speed: 8.0,
      range: weapon.range,
      projectileType: ProjectileType.Bullet,
      damage: weapon.damage,
    );
    dispatchAttackPerformed(
        weapon.type,
        character.x,
        character.y,
        character.z,
        angle,
    );
  }

  void playerFaceMouse(Player player){
      player.faceXY(
          player.mouseGridX,
          player.mouseGridY,
      );
  }

  void deactivateGameObject(GameObject gameObject, {int duration = 0}){
     if (!gameObject.active) return;
     gameObject.active = false;
     gameObject.collidable = false;
     gameObject.timer = duration;
     customOnGameObjectDeactivated(gameObject);
  }

  void onGridChanged() {
    scene.refreshGridMetrics();
    scene.dirty = true;
    for (final player in players) {
      player.writeGrid();
    }
  }

  void dispatchGameEventCharacterDeath(Character character){
    for (final player in players) {
      player.writeGameEvent(
        type: GameEventType.Character_Death,
        x: character.x,
        y: character.y,
        z: character.z,
        angle: character.velocityAngle,
      );
      player.writeByte(character.type);
    }
  }

  void removeFromEngine() {
    print("removeFromEngine()");
    engine.games.remove(this);
  }

  void setHourMinutes(int hour, int minutes) {}

  /// UPDATE

  var _timerUpdateAITargets = 0;

  void updateInProgress() {

    frame++;
    if (_timerUpdateAITargets-- <= 0) {
      _timerUpdateAITargets = 15;
      updateAITargets();
    }

    for (final gameObject in gameObjects){
       if (gameObject.active) continue;
       if (gameObject.timer <= 0) continue;
       gameObject.timer--;
       if (gameObject.timer > 0) continue;
       activateGameObject(gameObject);
    }

    customUpdate();
    updateCollisions();
    updateCharacters();
    updateProjectiles();
    updateProjectiles(); // called twice to fix collision detection
    updateCharacterFrames();
    sortGameObjects();
  }

  void updateStatus() {
    removeDisconnectedPlayers();
    if (players.length == 0) return;
    updateInProgress();
    for (final player in players) {
      player.writeAndSendResponse();
    }
  }

  bool containsPlayerWithName(String name) {
    for (final character in players) {
      if (character.name == name) return true;
    }
    return false;
  }

  var _nextCharacterAnimationFrame = 0;

  void updateCharacterFrames() {
    _nextCharacterAnimationFrame++;
    if (_nextCharacterAnimationFrame < 6) return;
    _nextCharacterAnimationFrame = 0;
    for (final character in characters) {
      if (character.animationFrame++ > 6){
        character.animationFrame = 0;
      }
    }
  }

  void revive(Player player) {
    player.setCharacterStateSpawning();
    player.health = player.maxHealth;
    player.collidable = true;
    customOnPlayerRevived(player);
    player.writePlayerMoved();
    clearCharacterTarget(player);
  }

  int countAlive(List<Character> characters) {
    var total = 0;
    for (final character in characters) {
      if (character.alive) total++;
    }
    return total;
  }

  Player spawnPlayer();

  void onPlayerSelectCharacterType(Player player, CharacterSelection value) {}

  void playersWriteWeather() {
    for (final player in players) {
      player.writeWeather();
    }
  }

  Character? getClosestEnemy({
    required double x,
    required double y,
    required Character character,
  }) {
    return findClosestVector3(
        positions: characters,
        x: x,
        y: y,
        z: character.z,
        where: (other) => other.alive && !onSameTeam(other, character));
  }

  Collider? getClosestCollider(double x, double y, Character character,
      {required double minDistance}) {
    return findClosestVector3<Character>(
      positions: characters,
      x: x,
      y: y,
      z: character.z,
      where: (other) =>
      other.alive &&
          other != character &&
          other.distanceFromXYZ(x, y, character.z) < minDistance,
    );
  }

  void activateGameObject(GameObject gameObject){
    gameObject.active = true;
    gameObject.collidable = true;
  }

  void applyDamageToCharacter({
    required dynamic src,
    required Character target,
    required int amount,
  }) {
    if (target.deadOrDying) return;
    final damage = min(amount, target.health);
    target.health -= damage;

    if (target.health <= 0) {
      if (target is Zombie){
        setCharacterStateDead(target);
      } else {
        setCharacterStateDying(target);
      }

      customOnCharacterKilled(target, src);

      if (target is AI){
        clearCharacterTarget(target);
        target.clearDest();
        target.clearPath();
      }

    } else {
      customOnCharacterDamageApplied(target, src, damage);
      target.setCharacterStateHurt();
    }
    dispatchGameEventCharacterHurt(target);

    if (target is AI) {
      onAIDamagedBy(target, src);
    }
  }

  /// unsafe to override
  void onAIKilled(AI ai){
    clearCharacterTarget(ai);
    ai.clearDest();
    ai.clearPath();
  }

  /// Can be safely overridden to customize behavior
  void onAIDamagedBy(AI ai, dynamic src){
    final targetAITarget = ai.target;
    if (targetAITarget == null) {
      ai.target = src;
      return;
    }
    final aiTargetDistance = distanceV2(ai, targetAITarget);
    final srcTargetDistance = distanceV2(src, ai);
    if (srcTargetDistance < aiTargetDistance) {
      ai.target = src;
    }
  }

  void dispatchGameEventCharacterHurt(Character character) {
    for (final player in players) {
      final targetVelocityAngle = character.velocityAngle;
      player.writeGameEvent(
        type: GameEventType.Character_Hurt,
        x: character.x,
        y: character.y,
        z: character.z,
        angle: targetVelocityAngle,
      );
      player.writeByte(character.type);
    }
  }

  void updateCharacters() {
    for (var i = 0; i < characters.length; i++) {
      final character = characters[i];
      updateCharacter(character);
      if (character is Player) {
        updatePlayer(character);
        customUpdatePlayer(character);
      }
    }
  }

  void updateCollisions() {
    resolveCollisions(characters);
    resolveCollisionsBetween(characters, gameObjects);
  }

  void resolveCollisions(List<Collider> colliders) {
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
        internalOnCollisionBetweenColliders(colliderJ, colliderI);
      }
    }
  }

  void resolveCollisionsBetween(
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
        if (a == b) continue;
        internalOnCollisionBetweenColliders(a, b);
      }
    }
  }

  void internalOnCollisionBetweenColliders(Collider a, Collider b){
    assert (a.collidable);
    assert (b.collidable);
    assert (a != b);
    if (a.physical && b.physical){
      resolveCollisionPhysics(a, b);
    }

    if (a is Player) {
      if (b is GameObject) {
         customOnCollisionBetweenPlayerAndGameObject(a, b);
      }
      customOnCollisionBetweenPlayerAndOther(a, b);
    }
    if (b is Player) {
      if (a is GameObject) {
         customOnCollisionBetweenPlayerAndGameObject(b, a);
      }
      customOnCollisionBetweenPlayerAndOther(b, a);
    }
    customOnCollisionBetweenColliders(a, b);
  }

  void resolveCollisionPhysics(Collider a, Collider b) {
    final combinedRadius = a.radius + b.radius;
    final totalDistance = getDistanceXY(a.x, a.y, b.x, b.y);
    final overlap = combinedRadius - totalDistance;
    if (overlap < 0) return;
    var xDiff = a.x - b.x;
    var yDiff = a.y - b.y;

    if (xDiff == 0 && yDiff == 0) {
      if (a.moveOnCollision){
        a.x += 5;
        xDiff += 5;
      }
      if (b.moveOnCollision){
        b.x -= 5;
        xDiff += 5;
      }
    }

    final ratio = 1.0 / getHypotenuse(xDiff, yDiff);
    final xDiffNormalized = xDiff * ratio;
    final yDiffNormalized = yDiff * ratio;
    final halfOverlap = overlap * 0.5;
    final targetX = xDiffNormalized * halfOverlap;
    final targetY = yDiffNormalized * halfOverlap;
    if (a.moveOnCollision){
      a.x += targetX;
      a.y += targetY;
    }
    if (b.moveOnCollision){
      b.x -= targetX;
      b.y -= targetY;
    }
  }

  void sortGameObjects() {
    sort(characters);
    sort(projectiles);
    sort(gameObjects);
  }

  void sort(List<Position3> items) {
    var start = 0;
    var end = items.length;
    for (var pos = start + 1; pos < end; pos++) {
      var min = start;
      var max = pos;
      var element = items[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (element.order <= items[mid].order) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      items.setRange(min + 1, pos + 1, items, min);
      items[min] = element;
    }
  }

  void setCharacterStateDying(Character character) {
    if (character.deadOrDying) return;
    character.health = 0;
    character.state = CharacterState.Dying;
    character.stateDurationRemaining = 10;
    character.onCharacterStateChanged();
    character.collidable = false;

    for (final character in characters) {
      if (character.target != character) continue;
      clearCharacterTarget(character);
    }

    for (final projectile in projectiles) {
      if (projectile.target != character) continue;
      projectile.target = null;
    }

    for (final player in players) {
      if (player.aimTarget != character) continue;
      player.aimTarget = null;
    }
  }

  void setCharacterStateChanging(Character character){
    if (character.deadOrBusy) return;
    dispatchV3(GameEventType.Character_Changing, character);
    character.setCharacterState(value: CharacterState.Changing, duration: 20);
  }

  void setCharacterStateDead(Character character) {
    if (character.state == CharacterState.Dead) return;

    dispatchGameEventCharacterDeath(character);
    character.health = 0;
    character.state = CharacterState.Dead;
    character.onCharacterStateChanged();
    character.collidable = false;

    for (final character in characters) {
      if (character.target != character) continue;
      clearCharacterTarget(character);
    }

    for (final projectile in projectiles) {
      if (projectile.target != character) continue;
      projectile.target = null;
    }
  }

  void changeCharacterHealth(Character character, int amount) {
    if (character.deadOrDying) return;
    character.health += amount;
    if (character.health > 0) return;
    setCharacterStateDying(character);
  }

  void deactivateProjectile(Projectile projectile) {
    assert(projectile.active);
    projectile.active = false;
    switch (projectile.type) {
      case ProjectileType.Orb:
        dispatch(GameEventType.Blue_Orb_Deactivated, projectile.x, projectile.y,
            projectile.z);
        break;
      default:
        break;
    }
  }

  void updateProjectiles() {
    var projectilesLength = projectiles.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      projectile.x += projectile.xv;
      projectile.y += projectile.yv;
      final target = projectile.target;
      if (target != null) {
        projectile.setVelocityTowards(target);
      } else if (projectile.overRange) {
        deactivateProjectile(projectile);
      }
    }
    projectilesLength = projectiles.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      if (projectile.collideWithEnvironment) continue;
      if (scene.getCollisionAt(projectile.x, projectile.y, projectile.z)) {
        deactivateProjectile(projectile);
      }
    }

    checkProjectileCollision(characters);
  }

  void refreshSpawns() {
    // for (final plane in scene.grid) {
    //   for (final row in plane) {
    //     for (final node in row) {
    //       if (node is NodeSpawn) nodeSpawnInstancesCreate(node);
    //     }
    //   }
    // }
  }

  // void nodeSpawnInstancesClear(NodeSpawn node) {
  //   for (var i = 0; i < characters.length; i++){
  //     final character = characters[i];
  //     if (character.spawn != node) continue;
  //     removeInstance(character);
  //     i--;
  //   }
  //   for (var i = 0; i < gameObjects.length; i++){
  //     final gameObject = gameObjects[i];
  //     if (gameObject.spawn != node) continue;
  //     removeInstance(gameObject);
  //     i--;
  //   }
  // }

  // void nodeSpawnInstancesCreate(NodeSpawn node) {
  //   for (var i = 0; i < node.spawnAmount; i++){
  //     spawnNodeInstance(node);
  //   }
  // }

  void removeInstance(dynamic instance) {
    if (instance == null) return;

    if (instance is Player) {
      instance.aimTarget = null;
      players.remove(instance);
    }
    if (instance is Character) {
      instance.spawn = null;
      characters.remove(instance);
      return;
    }
    if (instance is GameObject) {
      gameObjects.remove(instance);
      return;
    }
    if (instance is Projectile) {
      projectiles.remove(instance);
      return;
    }
    throw Exception();
  }

  void updatePlayer(Player player) {
    player.framesSinceClientRequest++;

    if (player.textDuration > 0) {
      player.textDuration--;
      if (player.textDuration == 0) {
        player.text = "";
      }
    }

    if (player.deadOrDying) return;

    if (player.weapon.durationRemaining > 0) {
      final weapon = player.weapon;
      weapon.durationRemaining--;
      if (weapon.durationRemaining == 0){
        weapon.state = AttackState.Aiming;
        player.lookRadian = player.mouseAngle;
        if (weapon.requiresRounds) {
          if (weapon.rounds == 0) {
            customOnPlayerWeaponRoundsExhausted(player, weapon);
          }
        }
        customOnPlayerWeaponReady(player);
      }
    }

    if (player.framesSinceClientRequest > 10) {
      player.setCharacterStateIdle();
    }

    final target = player.target;
    if (target == null) return;
    if (!player.busy) {
      player.face(target);
    }

    if (target is Collider) {

      if (!target.collidable) {
        clearCharacterTarget(player);
        return;
      }

      if (player.targetIsEnemy) {
        player.lookAt(target);
        if (player.withinAttackRange(target)) {
          playerUseWeapon(player, autoAim: false);
          player.setCharacterStateIdle();
          clearCharacterTarget(player);
          return;
        }
        setCharacterStateRunning(player);
        return;
      }

      if (target is Npc && player.targetIsAlly) {
        if (withinRadius(player, target, 100)) {
          if (!target.deadOrBusy) {
            target.face(player);
          }
          final onInteractedWith = target.onInteractedWith;
          if (onInteractedWith != null) {
            onInteractedWith(player);
            player.interactingWithNpc = true;
            player.setInteractingNpcName(target.name);
            onInteractedWith(player);
          }
          clearCharacterTarget(player);
          player.setCharacterStateIdle();
          return;
        }
        setCharacterStateRunning(player);
        return;
      }
      return;
    }

    if (player.distanceFromPos2(target) <= player.velocitySpeed) {
      clearCharacterTarget(player);
      player.setCharacterStateIdle();
      return;
    }

    // if (player.runningToTarget) {
    //   player.face(player.runTarget);
    // }

    setCharacterStateRunning(player);

    if (player.idling){
      final diff = Direction.getDifference(player.lookDirection, player.faceDirection);
      if (diff >= 2){
        player.faceAngle += piQuarter;
      } else if (diff <= -3) {
        player.faceAngle -= piQuarter;
      }
    }
  }

  void setCharacterStateRunning(Character character){
    character.setCharacterState(value: CharacterState.Running, duration: 0);
    // if (character.stateDuration == 0) {
    //   dispatchV3(
    //     GameEventType.Spawn_Dust_Cloud,
    //     character,
    //     angle: character.velocityAngle,
    //   );
    // }
  }

  void checkProjectileCollision(List<Collider> colliders) {
    final projectilesLength = projectiles.length;
    final collidersLength = colliders.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      final target = projectile.target;
      if (target != null) {
        if (withinRadius(projectile, target, 10.0)) {
          handleProjectileHit(projectile, target);
          continue;
        }
        continue;
      }
      for (var j = 0; j < collidersLength; j++) {
        final collider = colliders[j];
        if (!collider.collidable) continue;
        if (projectile.right < collider.left) continue;
        if (projectile.left > collider.right) continue;
        if (projectile.top > collider.bottom) continue;
        if (projectile.bottom < collider.top) continue;
        if (projectile.owner == collider) continue;
        if (target != null && onSameTeam(projectile, collider)) continue;
        handleProjectileHit(projectile, collider);
        break;
      }
    }
  }

  int getRandomWeaponIndex() =>
    randomItem([
      AttackType.Handgun,
      AttackType.Shotgun,
    ]);

  void handleProjectileHit(Projectile projectile, Position3 target) {
    projectile.active = false;
    if (target is Character) {
      applyHit(
        src: projectile.owner,
        target: target,
        damage: projectile.damage,
      );
    }
    projectile.owner = null;
    projectile.target = null;

    if (projectile.type == ProjectileType.Arrow) {
      dispatch(GameEventType.Arrow_Hit, target.x, target.y, target.z);
    }
    if (projectile.type == ProjectileType.Orb) {
      dispatch(
          GameEventType.Blue_Orb_Deactivated, target.x, target.y, target.z);
    }
  }

  void applyHit({
    required dynamic src,
    required Collider target,
    required int damage,
  }) {
    if (!target.collidable) return;
    if (target is Character) {
      if (onSameTeam(src, target)) return;
      if (target.deadOrDying) return;
    }

    // TODO Hack
    if (src is Zombie) {
      dispatchV3(GameEventType.Zombie_Strike, src);
    }
    if (target is Character) {
      applyDamageToCharacter(src: src, target: target, amount: damage);
    }

    if (target is Velocity) {
      (target as Velocity).applyForce(
        force: 20,
        angle: radiansV2(src, target),
      );
    }
  }

  void updateCharacterStatePerforming(Character character) {
    updateCharacterStateAttacking(character);
  }

  void updateCharacter(Character character) {
    if (character.dead) {
      if (character is AI) {
        updateRespawnAI(character);
      }
      return;
    }

    if (character is AI){
      updateAI(character);
    }

    updateCharacterMovement(character);
    resolveCharacterTileCollision(character);
    if (character.dying){
      if (character.stateDurationRemaining-- <= 0){
        setCharacterStateDead(character);
      }
      return;
    }

    updateCharacterState(character);
  }

  void updateAI(AI ai){
      if (ai.deadOrBusy) return;

      final target = ai.target;
      if (target != null) {
        if (ai.withinAttackRange(target)) {
          return ai.attackTarget(target);
        }
        // if ((ai.getDistance(target) < ai.chaseRange)) {
          ai.destX = target.x;
          ai.destY = target.y;
        // }
      }

      if (!ai.arrivedAtDest) {
        ai.faceAngle = ai.getDestinationAngle();
        return  setCharacterStateRunning(ai);
      }

      if (ai.pathIndex > 0){
        ai.pathIndex--;
        ai.destX = ai.pathX[ai.pathIndex];
        ai.destY = ai.pathY[ai.pathIndex];
        ai.faceAngle = ai.getDestinationAngle();
        setCharacterStateRunning(ai);
        return;
      }
      ai.state = CharacterState.Idle;
      ai.applyBehaviorWander(this);
  }

  void updateCharacterState(Character character){
    if (character.stateDurationRemaining > 0) {
      character.stateDurationRemaining--;
      if (character.stateDurationRemaining == 0) {
        return character.setCharacterStateIdle();
      }
    }
    switch (character.state) {
      case CharacterAction.Idle:
      // only do this if not struck or recovering
      // speed *= 0.75;
        break;
      case CharacterState.Running:
        character.applyForce(force: 1.0, angle: character.faceAngle);
        if (character.stateDuration % 10 == 0) {
          dispatch(
            GameEventType.Footstep,
            character.x,
            character.y,
            character.z,
          );
        }
        break;
      case CharacterState.Performing:
        updateCharacterStatePerforming(character);
        break;
      case CharacterState.Spawning:
        if (character.stateDurationRemaining == 1){
          customOnCharacterSpawned(character);
        }
        if (character.stateDuration == 0) {
          if (this is Player){
            (this as Player).writePlayerEvent(PlayerEvent.Spawn_Started);
          }
        }
        break;
    }
    character.stateDuration++;
  }

  void updateCharacterMovement(Character character) {
    character.z -= character.zVelocity;
    const gravity = 0.98;
    character.zVelocity += gravity;

    const minVelocity = 0.005;
    if (character.velocitySpeed <= minVelocity) return;

    character.x += character.xv;
    character.y += character.yv;

    // final nodeType = character.getNodeTypeInDirection(
    //   game: this,
    //   angle: character.velocityAngle,
    //   distance: character.radius,
    // );
    //
    // if (nodeType == NodeType.Tree_Bottom || nodeType == NodeType.Torch) {
    //   final nodeCenterX = character.indexRow * tileSize + tileSizeHalf;
    //   final nodeCenterY = character.indexColumn * tileSize + tileSizeHalf;
    //   final dis = character.getDistanceXY(nodeCenterX, nodeCenterY);
    //   const treeRadius = 5;
    //   final overlap = dis - treeRadius - character.radius;
    //   if (overlap < 0) {
    //     character.x -= getAdjacent(character.velocityAngle, overlap);
    //     character.y -= getOpposite(character.velocityAngle, overlap);
    //   }
    // }

    character.applyFriction(0.75);
  }

  void updateRespawnAI(AI ai) {
    assert(ai.dead);
    if (ai.spawn == null) return;
    if (ai.respawn-- > 0) return;
    respawnAI(ai);
  }

  void respawnAI(AI ai){
    final
    spawn = ai.spawn;
    if (spawn == null){
      throw Exception("ai.spawn is null");
    }
    final
    distance = randomBetween(0, spawn.spawnRadius);
    final
    angle = randomAngle();
    ai.x = spawn.x + getAdjacent(angle, distance);
    ai.y = spawn.y + getOpposite(angle, distance);
    ai.z = ai.spawnZ;
    ai.clearDest();
    clearCharacterTarget(ai);
    ai.clearPath();
    ai.collidable = true;
    ai.health = ai.maxHealth;
    ai.target = null;
    ai.xv = 0;
    ai.xv = 0;
    ai.spawnX = ai.x;
    ai.spawnY = ai.y;
    ai.spawnZ = ai.z;
    ai.setCharacterStateSpawning();
    customOnAIRespawned(ai);
  }

  Projectile spawnProjectileOrb({required Character src, required int damage}) {
    dispatchV3(GameEventType.Blue_Orb_Fired, src);
    return
    spawnProjectile(
      src: src,
      accuracy: 0,
      speed: 4.5,
      range: src.equippedRange,
      target: src.target,
      projectileType: ProjectileType.Orb,
      angle: src.target != null ? null : (src is Player ? src.lookRadian : src.faceAngle),
      damage: damage,
    );
  }

  void spawnProjectileArrow({
    required Character src,
    required int damage,
    required double range,
    double accuracy = 0,
    Position3? target,
    double? angle,
  }) {
    dispatch(GameEventType.Arrow_Fired, src.x, src.y, src.z);
    spawnProjectile(
      src: src,
      accuracy: accuracy,
      speed: 7,
      range: range,
      target: target,
      angle: target != null ? null : angle ?? src.faceAngle,
      projectileType: ProjectileType.Arrow,
      damage: damage,
    );
  }

  Projectile spawnProjectileFireball(
      Character src, {
        required int damage,
        required double range,
        double? angle,
      }) {
    dispatchAttackPerformed(
      AttackType.Fireball,
      src.x,
      src.y,
      src.z,
      angle ?? src.faceAngle,
    );
    return
      spawnProjectile(
      src: src,
      accuracy: 0,
      speed: 5,
      range: range,
      target: src.target,
      angle: angle,
      projectileType: ProjectileType.Fireball,
      damage: damage,
    );
  }

  Projectile spawnProjectileBullet({
    required Character src,
    double accuracy = 0,
    double speed = 12,
  }) =>
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: src.faceAngle,
      speed: speed,
      range: src.equippedRange,
      projectileType: ProjectileType.Bullet,
      damage: src.weapon.damage,
    );

  void fireAssaultRifle(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      speed: 8.0,
      range: 300,
      projectileType: ProjectileType.Bullet,
      damage: 5,
    );
    dispatchAttackPerformed(AttackType.Assault_Rifle, src.x, src.y, src.z, angle);
  }

  // void fireArrow(Character src, double angle) {
  //   spawnProjectile(
  //     src: src,
  //     accuracy: 0,
  //     angle: angle,
  //     speed: 5.0,
  //     range: 300,
  //     projectileType: ProjectileType.Arrow,
  //     damage: 5,
  //   );
  //   dispatchAttackPerformed(AttackType.Bow, src.x, src.y, src.z, angle);
  // }

  void fireRifle(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      speed: 15.0,
      range: 600,
      projectileType: ProjectileType.Bullet,
      damage: 10,
    );
    dispatchAttackPerformed(AttackType.Rifle, src.x, src.y, src.z, angle);
  }

  void characterSpawnProjectileFireball(Character character, {
    required double angle,
    double speed = 3.0,
    double range = 300,
    int damage = 5,
  }) {
    spawnProjectile(
      src: character,
      projectileType: ProjectileType.Fireball,
      accuracy: 0, // TODO delete accuracy
      angle: angle,
      speed: speed,
      range: range,
      damage: damage,
    );
    dispatchAttackPerformed(AttackType.Fireball, character.x, character.y, character.z, angle);
  }

  void characterFireShotgun(Character src, double angle) {
    if (src.weapon.durationRemaining > 0) return;

    src.applyForce(
      force: 6.0,
      angle: angle + pi,
    );
    src.weapon.durationRemaining = src.weapon.duration;

    for (var i = 0; i < 5; i++) {
      spawnProjectile(
        src: src,
        accuracy: 0,
        angle: angle + giveOrTake(0.25),
        speed: 8.0,
        range: src.weapon.range,
        projectileType: ProjectileType.Bullet,
        damage:src.weapon.damage,
      );
    }
    dispatchAttackPerformed(AttackType.Shotgun, src.x, src.y, src.z, angle);
  }

  Projectile spawnProjectile({
    required Character src,
    required double speed,
    required double range,
    required int projectileType,
    required int damage,
    double accuracy = 0,
    double? angle = 0,
    Position3? target,
  }) {
    final projectile = getInstanceProjectile();
    var finalAngle = angle;
    if (finalAngle == null) {
      if (target != null && target is Collider) {
        finalAngle = target.getAngle(src);
      } else {
        finalAngle = src.faceAngle;
      }
    }
    projectile.damage = damage;
    projectile.collidable = true;
    projectile.active = true;
    if (target is Collider) {
      projectile.target = target;
    }
    projectile.start.x = src.x;
    projectile.start.y = src.y;
    projectile.x = src.x;
    projectile.y = src.y;
    projectile.z = src.z + tileHeightHalf;
    projectile.setVelocity(finalAngle + giveOrTake(accuracy), speed);
    projectile.faceAngle = finalAngle;
    projectile.owner = src;
    projectile.range = range;
    projectile.type = projectileType;
    return projectile;
  }

  Projectile getInstanceProjectile() {
    for (var i = 0; i < projectiles.length; i++) {
      if (projectiles[i].active) continue;
      return projectiles[i];
    }
    final projectile = Projectile();
    projectiles.add(projectile);
    return projectile;
  }

  Zombie spawnZombieAtIndex(int i){
    final indexZ = i ~/ scene.gridArea;
    var remainder = i - (indexZ * scene.gridArea);
    final indexRow = remainder ~/ scene.gridColumns;
    remainder -= indexRow * scene.gridColumns;
    final indexColumn = remainder;
    final zombie = spawnZombie(
      x: indexRow * nodeSize,
      y: indexColumn * nodeSize,
      z: indexZ * nodeHeight,
      health: 3,
      team: 100,
      damage: 1,
    );
    zombie.spawnNodeIndex = i;
    return zombie;
  }

  GameObject spawnGameObjectAtIndex({required int index, required int type}){
    final instance = GameObject(
      x: 0,
      y: 0,
      z: 0,
      type: type,
    );
    moveV3ToNodeIndex(instance, index);
    gameObjects.add(instance);
    return instance;
  }

  Zombie spawnZombie({
    required double x,
    required double y,
    required double z,
    required int health,
    required int team,
    required int damage,
    double speed = RunSpeed.Regular,
    List<Vector2>? objectives,
    double wanderRadius = 100.0,
  }) {
    assert(team >= 0 && team <= 256);
    final zombie = getZombieInstance();
    zombie.team = team;
    zombie.state = CharacterState.Idle;
    zombie.stateDurationRemaining = 0;
    zombie.maxHealth = health;
    zombie.health = health;
    zombie.collidable = true;
    zombie.x = x;
    zombie.y = y;
    zombie.z = z;
    zombie.spawnX = x;
    zombie.spawnY = y;
    zombie.clearDest();
    zombie.wanderRadius = wanderRadius;
    return zombie;
  }

  // Zombie spawnZombieAtNodeSpawn({
  //   required NodeSpawn node,
  //   required int health,
  //   required int team,
  //   required int damage,
  //   int respawnDuration = 100,
  //   double speed = RunSpeed.Regular,
  //   List<Vector2>? objectives,
  //   double wanderRadius = 100.0,
  // }) {
  //   assert(team >= 0 && team <= 256);
  //   final zombie = getZombieInstance();
  //   zombie.team = team;
  //   zombie.spawn = node;
  //   zombie.respawn = respawnDuration;
  //   zombie.state = CharacterState.Idle;
  //   zombie.stateDurationRemaining = 0;
  //   zombie.maxHealth = health;
  //   zombie.health = health;
  //   zombie.collidable = true;
  //   zombie.x = node.x;
  //   zombie.y = node.y;
  //   zombie.z = node.z;
  //   zombie.spawnX = node.x;
  //   zombie.spawnY = node.y;
  //   zombie.spawnZ = node.z;
  //   zombie.clearDest();
  //   zombie.wanderRadius = wanderRadius;
  //   return zombie;
  // }

  Zombie getZombieInstance() {
    for (final character in characters) {
      if (character.alive) continue;
      if (character is Zombie) return character;
    }
    final zombie = Zombie(
      x: 0,
      y: 0,
      z: 0,
      health: 10,
      damage: 1,
      game: this,
      team: Teams.neutral,
    );
    characters.add(zombie);
    return zombie;
  }

  Rat getInstanceRat() {
    for (final character in characters) {
      if (character.alive) continue;
      if (character is Rat) return character;
    }
    final instance = Rat(
      z: 0,
      row: 0,
      column: 0,
      health: 10,
      damage: 1,
      game: this,
      team: Teams.evil,
    );
    characters.add(instance);
    return instance;
  }

  /// GameEventType
  void dispatchV3(int type, Position3 position, {double angle = 0}) {
    dispatch(type, position.x, position.y, position.z, angle);
  }

  /// GameEventType
  void dispatch(int type, double x, double y, double z, [double angle = 0]) {
    for (final player in players) {
      player.writeGameEvent(type: type, x: x, y: y, z: z, angle: angle);
    }
  }

  void dispatchAttackPerformed(int attackType, double x, double y, double z, double angle){
    for (final player in players) {
      player.writeGameEvent(
        type: GameEventType.Attack_Performed,
        x: x,
        y: y,
        z: z,
        angle: angle,
      );
      player.writeByte(attackType);
    }
  }

  void dispatchAttackTypeEquipped(int attackType, double x, double y, double z, double angle){
    for (final player in players) {
      player.writeGameEvent(
        type: GameEventType.Weapon_Type_Equipped,
        x: x,
        y: y,
        z: z,
        angle: angle,
      );
      player.writeByte(attackType);
    }
  }

  void updateAITargets() {
    for (final character in characters) {
      if (!character.alive) continue;
      if (character is AI == false) continue;
      updateAITarget(character as AI);
    }
  }

  void updateAITarget(AI ai){
    var target = ai.target;
    final targetSet = target != null;
    if (target != null && !ai.withinChaseRange(target)) {
      ai.target = null;
      ai.clearDest();
    }

    var targetDistance = 9999999.0;

    for (final other in characters) {
      if (!other.alive) continue;
      if (onSameTeam(other, ai)) continue;
      if (!ai.withinViewRange(other)) continue;
      final npcDistance = ai.getDistance(other);
      if (npcDistance >= targetDistance) continue;
      setNpcTarget(ai, other);
      targetDistance = npcDistance;
    }
    target = ai.target;
    if (target == null) return;
    if (targetDistance < 100) return;
    npcSetPathTo(ai, target);
    if (!targetSet){
      dispatchGameEventAITargetAcquired(ai);
    }
  }

  void dispatchGameEventAITargetAcquired(AI ai){
    for (final player in players) {
      player.writeGameEvent(
        type: GameEventType.AI_Target_Acquired,
        x: ai.x,
        y: ai.y,
        z: ai.z,
        angle: 0,
      );
      player.writeByte(ai.type);
    }
  }

  void setNpcTarget(AI ai, Position3 value) {
    if (value is Team) {
      assert(!onSameTeam(ai, value));
    }
    assert(ai.alive);
    ai.target = value;
  }

  void removeDisconnectedPlayers() {
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.framesSinceClientRequest++ < 300) continue;
      if (!removePlayer(player)) continue;
      i--;
      playerLength--;
      print("Removed disconnected player");
    }
  }

  bool removePlayer(Player player) {
    if (!players.remove(player)) return false;
    characters.remove(player);
    customOnPlayerDisconnected(player);
    if (player.scene.dirty && player.scene.name.isNotEmpty) {
      writeSceneToFile(scene);
    }
    return true;
  }

  void npcSetRandomDestination(AI ai, {int radius = 10}) {
    // final node = scene.getNodeByPosition(ai);
    // if (!node.open) return;
    // final minColumn = max(0, node.column - radius);
    // final maxColumn = min(scene.numberOfColumns, node.column + radius);
    // final minRow = max(0, node.row - radius);
    // final maxRow = min(scene.numberOfRows, node.row + radius);
    // final randomColumn = randomInt(minColumn, maxColumn);
    // final randomRow = randomInt(minRow, maxRow);
    // final randomTile = scene.nodes[randomRow][randomColumn];
    // npcSetPathToTileNode(ai, randomTile);
  }

  void npcSetPathTo(AI ai, Position3 position) {
    // npcSetPathToTileNode(ai, scene.getNodeByPosition(position));
  }

  // void npcSetPathToTileNode(AI ai, Node node) {
  //   pathFindDestination = node;
  //   pathFindAI = ai;
  //   pathFindSearchID++;
  //   ai.pathIndex = -1;
  //   // scene.visitNodeFirst(scene.getNodeByPosition(ai));
  // }

  /// This represents a standard attack from the character, no powers
  void updateCharacterStateAttacking(Character character) {
    const framePerformStrike = 10;
    final stateDuration = character.stateDuration;
    final equippedDamage = character.equippedDamage;
    if (character is Zombie) {
      if (stateDuration != framePerformStrike) return;
      final attackTarget = character.target;
      if (attackTarget == null) return;
      if (attackTarget is Collider) {
        applyHit(
          src: character,
          target: attackTarget,
          damage: equippedDamage,
        );
        clearCharacterTarget(character);
      }
      return;
    }

    final weaponType = character.weapon.type;
    if (weaponType == AttackType.Blade) {
      if (stateDuration == 7) {
        dispatchV3(GameEventType.Sword_Woosh, character);
      }
    }
    if (weaponType == AttackType.Unarmed) {
      if (stateDuration == 7) {
        // dispatchV3(GameEventType.Arm_Swing, character);
      }
    }
    if (weaponType == AttackType.Handgun) {
      if (stateDuration == 1) {
        if (character.equippedIsEmpty) {
          // dispatchV3(GameEventType.Clip_Empty, character);
          return;
        }
        return;
      }
      if (stateDuration == 2) {
        if (character.equippedIsEmpty) {
          return;
        }
        spawnProjectileBullet(
          src: character,
          accuracy: 0,
          speed: 12.0,
        );
        return;
      }
    }

    if (character.equippedTypeIsShotgun) {
      if (stateDuration == 1) {
        if (character.equippedIsEmpty) {
          // dispatchV3(GameEventType.Ammo_Acquired, character);
          return;
        }
        // dispatchV3(GameEventType.Shotgun_Fired, character);
        final totalBullets = 4;
        for (int i = 0; i < totalBullets; i++) {
          spawnProjectileBullet(
            src: character,
            accuracy: 0,
            speed: 12.0,
          );
        }
      }
    }

    if (character.equippedTypeIsBow && stateDuration == 1) {
      dispatchV3(GameEventType.Draw_Bow, character);
    }

    if (stateDuration != framePerformStrike)
      return;

    if (character.equippedTypeIsStaff) {
      spawnProjectileOrb(src: character, damage: equippedDamage);
      clearCharacterTarget(character);
      return;
    }

    if (character.equippedTypeIsBow) {
      dispatchV3(GameEventType.Release_Bow, character);
         spawnProjectileArrow(
          src: character,
          damage: equippedDamage,
          target: character.target,
          range: character.equippedRange,
         );
      clearCharacterTarget(character);
      return;
    }
    if (character.equippedIsMelee) {
      spawnProjectile(
        src: character,
        speed: 3,
        range: character.equippedRange * 2,
        projectileType: ProjectileType.Wave,
        damage: 1,
        angle: character.faceAngle,
      );

      final attackTarget = character.target;
      if (attackTarget != null) {
        if (attackTarget is Collider && attackTarget.collidable) {
          applyHit(
              src: character, target: attackTarget, damage: equippedDamage);
          clearCharacterTarget(character);
          return;
        }
        clearCharacterTarget(character);
      }
      final zombieHit = raycastHit(
          character: character,
          colliders: characters,
          range: character.equippedRange);
      if (zombieHit != null) {
        applyHit(
          src: character,
          target: zombieHit,
          damage: equippedDamage,
        );
        return;
      }
      // final dynamicObjectHit = raycastHit(
      //     character: character,
      //     colliders: gameObjects,
      //     range: character.equippedRange
      // );
      // if (dynamicObjectHit != null) {
      //   applyHit(
      //     src: character,
      //     target: dynamicObjectHit,
      //     damage: equippedDamage,
      //   );
      // }
      return;
    }
  }

  Npc addNpc({
    required String name,
    required int row,
    required int column,
    required int z,
    required Weapon weapon,
    Function(Player player)? onInteractedWith,
    int head = HeadType.None,
    int armour = BodyType.shirtCyan,
    int pants = LegType.brown,
    int team = 1,
    int health = 10,
    double wanderRadius = 0,
  }) {
    final npc = Npc(
      name: name,
      onInteractedWith: onInteractedWith,
      x: 0,
      y: 0,
      z: 0,
      weapon: weapon,
      team: team,
      health: health,
      wanderRadius: wanderRadius,
      game: this,
    );
    npc.equippedHead = head;
    npc.equippedArmour = armour;
    npc.equippedLegs = pants;
    npc.indexRow = row;
    npc.indexColumn = column;
    npc.indexZ = z;
    npc.spawnX = npc.x;
    npc.spawnY = npc.y;
    npc.clearDest();
    characters.add(npc);
    return npc;
  }

  double angle2(double adjacent, double opposite) {
    if (adjacent > 0) {
      return pi2 - (atan2(adjacent, opposite) * -1);
    }
    return atan2(adjacent, opposite);
  }

  void playerDeleteEditorSelectedGameObject(Player player){
    removeInstance(player.editorSelectedGameObject);
    playerDeselectEditorSelectedGameObject(player);
  }

  void playerDeselectEditorSelectedGameObject(Player player){
    if (player.editorSelectedGameObject == null) return;
    player.editorSelectedGameObject = null;
    player.writePlayerEvent(PlayerEvent.GameObject_Deselected);
  }

  void spawnGameObjectLoot({
    required double x,
    required double y,
    required double z,
    required int type,
  }){
    // TODO
  }

  Weapon buildWeaponByType(int type){
    switch(type){
      case AttackType.Shotgun:
        return buildWeaponShotgun();
      case AttackType.Handgun:
        return buildWeaponHandgun();
      case AttackType.Blade:
        return buildWeaponBlade();
      case AttackType.Bow:
        return buildWeaponBow();
      default:
        throw Exception("cannot build weapon for type $type");
    }
  }

  void resolveCharacterTileCollision(Character character) {
    const distance = 3;
    final stepHeight = character.z + tileHeightHalf;

    if (scene.getCollisionAt(character.left, character.top, stepHeight)) {
      character.x += distance;
      character.y += distance;
    }
    else
    if (scene.getCollisionAt(character.right, character.bottom, stepHeight)) {
      character.x -= distance;
      character.y -= distance;
    }
    if (scene.getCollisionAt(character.left, character.bottom, stepHeight)) {
      character.x += distance;
      character.y -= distance;
    } else
    if (scene.getCollisionAt(character.right, character.top, stepHeight)) {
      character.x -= distance;
      character.y += distance;
    }

    if (scene.getNodeInBoundsXYZ(character.x, character.y, character.z)) {
      final nodeAtFeetIndex = scene.getNodeIndexXYZ(character.x, character.y, character.z);
      final nodeAtFeetOrientation = scene.nodeOrientations[nodeAtFeetIndex];

      if (nodeAtFeetOrientation == NodeOrientation.Solid){
        character.z = ((character.z ~/ tileHeight) * tileHeight) + tileHeight;
        character.zVelocity = 0;
      } else
      if (nodeAtFeetOrientation != NodeOrientation.None) {
        final bottom = (character.z ~/ tileHeight) * tileHeight;
        final percX = ((character.x % tileSize) / tileSize);
        final percY = ((character.y % tileSize) / tileSize);
        final nodeTop = bottom + (NodeOrientation.getGradient(nodeAtFeetOrientation, percX, percY) * nodeHeight);
        if (nodeTop > character.z){
          character.z = nodeTop;
          character.zVelocity = 0;
        }
      }
    } else {
      if (character.z < -100){
        setCharacterStateDead(character);
      }
    }
  }

  void setNode({
    required int nodeIndex,
    required int nodeType,
    required int nodeOrientation,
  }) {
    assert (nodeIndex >= 0);

    if (nodeIndex >= scene.gridVolume) {
      throw Exception("game.setNode(nodeIndex: $nodeIndex) - node index out of bounds");
    }
    if (
      nodeType == scene.nodeTypes[nodeIndex] &&
      nodeOrientation == scene.nodeOrientations[nodeIndex]
    ) return;

    if (!NodeType.supportsOrientation(nodeType, nodeOrientation)){
      nodeOrientation = NodeType.getDefaultOrientation(nodeType);
    }
    scene.dirty = true;
    scene.nodeOrientations[nodeIndex] = nodeOrientation;
    scene.nodeTypes[nodeIndex] = nodeType;
    for (final player in players){
      player.writeNode(nodeIndex);
    }
  }

  void setCharacterTarget(Character character, Position3 target){
    character.target = target;
    if (character is Player) {
      if (character.target == character.runTarget){
        character.writeTargetPosition();
      } else {
        character.writeTargetPositionNone();
      }
    }
  }

  void clearCharacterTarget(Character character){
    if (character.target == null) return;
    character.target = null;
    if (character is Player){
      character.writeTargetPositionNone();
    }
  }
}

