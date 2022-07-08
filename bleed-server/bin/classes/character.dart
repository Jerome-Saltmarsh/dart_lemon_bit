import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../functions/withinRadius.dart';
import 'collider.dart';
import 'game.dart';
import 'position3.dart';
import 'card_abilities.dart';
import 'components.dart';
import 'weapon.dart';

class Character extends Collider with Team, Health, Velocity, Material {
  late double walkingSpeed;
  CardAbility? ability = null;
  double accuracy = 0;
  var state = CharacterState.Idle;
  var stateDurationRemaining = 0;
  var stateDuration = 0;
  var animationFrame = 0;
  var frozenDuration = 0;
  /// the character that was highlighted as the character began attacking
  /// This forces a hit to occur even if the target goes out of range of the attack
  Position3? target;
  var invincible = false;
  final techTree = TechTree();
  Weapon equippedWeapon;
  var equippedArmour = ArmourType.shirtCyan;
  var equippedHead = HeadType.None;
  var equippedPants = PantsType.white;

  int get direction => convertAngleToDirection(angle);

  void set direction(int value){
    angle = convertDirectionToAngle(value);
  }

  bool get running => state == CharacterState.Running;

  bool get idling => state == CharacterState.Idle;

  bool get busy => stateDurationRemaining > 0;

  bool get deadOrBusy => dead || busy;

  int get equippedDamage => equippedWeapon.damage;
  double get equippedRange => WeaponType.getRange(equippedWeapon.type);
  int get equippedAttackDuration => 25;
  bool get equippedTypeIsBow => equippedWeapon.type == WeaponType.Bow;
  bool get unarmed => equippedWeapon.type == WeaponType.Unarmed;
  bool get equippedTypeIsShotgun => equippedWeapon.type == WeaponType.Shotgun;
  bool get equippedIsMelee => WeaponType.isMelee(equippedWeapon.type);
  bool get equippedIsEmpty => false;
  int get equippedLevel => 1;

  Character({
    required double x,
    required double y,
    required double z,
    required int health,
    required this.equippedWeapon,
    double speed = 5.0,
    int team = Teams.none,
    this.equippedArmour = ArmourType.tunicPadded,
    this.equippedHead = HeadType.None,

  }) : super(x: x, y: y, z: z, radius: 7) {
    maxHealth = health;
    this.health = health;
    walkingSpeed = speed;
    this.team = team;
    this.material = MaterialType.Flesh;
  }

  void applyVelocity() {
     if (speed > walkingSpeed) return;
     speed = walkingSpeed;
  }

  void customUpdateCharacter(Game game){

  }

  void attackTarget(Position3 target) {
    if (deadOrBusy) return;
    face(target);
    setCharacterStatePerforming(duration: equippedAttackDuration);
    this.target = target;
  }

  void runAt(Position target) {
    face(target);
    setCharacterStateRunning();
  }

  void updateCharacter(Game game){
    if (dead) return;

    customUpdateCharacter(game);
    // if (this is AI) {
    //   updateAI(this);
    //   updateAICharacterState(character);
    // }
    updateMovement();

    // if (frozenDuration > 0) {
    //   character.frozenDuration--;
    // }

    if (running) {
      if (stateDuration % 10 == 0) {
        game.dispatch(GameEventType.Footstep, x, y, z);
      }
    } else if (stateDurationRemaining > 0) {
      stateDurationRemaining--;
      if (stateDurationRemaining == 0) {
        setCharacterStateIdle();
      }
    }

    game.scene.resolveCharacterTileCollision(this, game);

    switch (state) {
      case CharacterAction.Idle:
        speed *= 0.75;
        break;

      case CharacterState.Running:
        applyVelocity();
        break;

      case CharacterState.Performing:
        game.updateCharacterStatePerforming(this);
        break;
    }
    stateDuration++;
  }

  void setCharacterStatePerforming({required int duration}){
    setCharacterState(value: CharacterState.Performing, duration: duration);
  }

  void setCharacterStateRunning(){
    setCharacterState(value: CharacterState.Running, duration: 0);
  }

  void setCharacterStateHurt(){
    setCharacterState(value: CharacterState.Hurt, duration: 0);
  }

  void setCharacterStateIdle(){
    setCharacterState(value: CharacterState.Idle, duration: 0);
  }

  void onCharacterStateChanged(){
    stateDuration = 0;
    animationFrame = 0;
  }

  void setCharacterState({required int value, required int duration}) {
    assert(value >= 0);
    assert(value <= 5);
    if (dead) return;
    if (state == value) return;

    if (value == CharacterState.Dead) {
      state = CharacterState.Dead;
      return;
    }

    if (value == CharacterState.Hurt) {
      const duration = 10;
      stateDurationRemaining = duration;
      state = value;
      stateDuration = 0;
      animationFrame = 0;
      ability = null;
      return;
    }

    if (busy) return;

    switch (value) {
      case CharacterState.Idle:
        target = null;
        break;
      case CharacterState.Changing:
        stateDurationRemaining = 10;
        break;
      case CharacterState.Performing:
        stateDurationRemaining = 20;
        break;
      default:
        break;
    }
    state = value;
    stateDuration = 0;
    animationFrame = 0;
  }

  void updateMovement() {
    const minVelocity = 0.005;
    if (speed <= minVelocity) return;
    x += xv;
    y += yv;
    speed *= 0.75; // friction
  }

  bool withinAttackRange(Position3 target){
    if (target is Collider){
      return withinRadius(this, target, equippedRange + (target.radius * 0.5));
    }
    return withinRadius(this, target, equippedRange);
  }

  void face(Position position) {
    assert(!deadOrBusy);
    angle = this.getAngle(position);
  }

  int getTechTypeLevel(int type) {
    switch(type){
      case TechType.Unarmed:
        return 1;
      case TechType.Pickaxe:
        return techTree.pickaxe;
      case TechType.Sword:
        return techTree.sword;
      case TechType.Bow:
        return techTree.bow;
      case TechType.Axe:
        return techTree.axe;
      case TechType.Hammer:
        return techTree.hammer;
      default:
        throw Exception("cannot get tech type level. type: $type");
    }
  }
}

bool onSameTeam(dynamic a, dynamic b){
  if (a == b) return true;
  if (a is Team == false) return false;
  if (b is Team == false) return false;
  if (a.team == 0) return false;
  return a.team == b.team;
}

class RunSpeed {
   static const Slow = 1.0;
   static const Regular = 2.0;
   static const Fast = 3.0;
   static const Very_Fast = 4.0;
}

