

import 'package:lemon_math/library.dart';

import '../classes/library.dart';
import '../common/game_waves_response.dart';
import '../common/library.dart';
import '../common/type_position.dart';

class GameWaves extends Game {

  static const framesBetweenRounds = 600;

  var timer = framesBetweenRounds;
  var remaining = 0;
  var round = 1;

  GameWaves({required Scene scene}) : super(scene);

  int mapAttackTypeToCost(int attackType) => {
      AttackType.Blade: 3,
      AttackType.Assault_Rifle: 10,
      AttackType.Handgun: 5,
      AttackType.Rifle: 15,
  }[attackType] ?? 0;

  int mapAttackTypeToPosition(int attackType) => {
    AttackType.Assault_Rifle: TypePosition.Primary,
    AttackType.Rifle: TypePosition.Primary,
    AttackType.Shotgun: TypePosition.Primary,
    AttackType.Handgun: TypePosition.Secondary,
    AttackType.Revolver: TypePosition.Secondary,
    AttackType.Fireball: TypePosition.Secondary,
    AttackType.Bow: TypePosition.Secondary,
    AttackType.Blade: TypePosition.Tertiary,
    AttackType.Baseball_Bat: TypePosition.Tertiary,
  }[attackType] ?? 0;

  void writePurchase(Player player, int type){
    player.writeByte(ServerResponse.Game_Waves);
    player.writeByte(GameWavesResponse.purchase);
    player.writeByte(mapAttackTypeToPosition(type));
    player.writeByte(type);
    player.writeInt(mapAttackTypeToCost(type));
  }

  void movePlayerToCrystal(Player player){
    final crystal = findGameObjectByType(GameObjectType.Crystal);
    if (crystal == null) return;
    player.x = crystal.x;
    player.y = crystal.y;
    player.z = crystal.z;
    move(player, randomAngle(), 75);
  }

  void playerWriteRound(Player player){
    player.writeByte(ServerResponse.Game_Waves);
    player.writeByte(GameWavesResponse.round);
    player.writeInt(round);
  }

  @override
  Player spawnPlayer() {
    return Player(game: this, weapon: buildWeaponHandgun());
  }

  @override
  void customInitPlayer(Player player) {
    player.points = 50;
    player.setCharacterStateSpawning();
    movePlayerToCrystal(player);
    playerWriteRound(player);

    player.writeByte(ServerResponse.Game_Waves);
    player.writeByte(GameWavesResponse.clear_upgrades);
    writePurchase(player, AttackType.Assault_Rifle);
    writePurchase(player, AttackType.Rifle);
    writePurchase(player, AttackType.Shotgun);
    writePurchase(player, AttackType.Handgun);
    writePurchase(player, AttackType.Revolver);
    writePurchase(player, AttackType.Crossbow);
    writePurchase(player, AttackType.Bow);
    writePurchase(player, AttackType.Fireball);
    writePurchase(player, AttackType.Blade);
    writePurchase(player, AttackType.Staff);
    writePurchase(player, AttackType.Baseball_Bat);
    player.writeEnvironmentShade(Shade.Medium);
    player.writeEnvironmentRain(Rain.Light);
  }

  @override
  void customUpdate() {
    if (timer <= 0) {
      return;
    }
    timer--;

    for (final player in players) {
      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.timer);
      player.writePercentage(timer / framesBetweenRounds);
    }

    if (timer == 0)
      spawnCreeps();

  }

  void spawnCreeps(){
    // for (final row in scene.grid) {
    //   for (final column in row) {
    //     for (final node in column){
    //       if (node is NodeSpawn) {
    //         for (var i = 0; i < round * 3; i++){
    //           remaining++;
    //           final zombie = spawnZombie(
    //             x: node.x,
    //             y: node.y,
    //             z: node.z,
    //             health: 2,
    //             team: Teams.evil,
    //             damage: 1,
    //           );
    //           zombie.chaseRange = 99999;
    //           zombie.viewRange = 99999;
    //           zombie.maxSpeed = 1.0;
    //         }
    //       }
    //     }
    //   }
    // }
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
    if (target is AI) {
      remaining--;
      spawnGameObjectLoot(
        x: target.x,
        y: target.y,
        z: target.z,
        type: 0,
      );

      if (remaining == 0){
        timer = framesBetweenRounds;
        round++;
        players.forEach(onNextRoundStart);
      }
    }
  }

  void onNextRoundStart(Player player){
    movePlayerToCrystal(player);
    playerWriteRound(player);
    player.health = player.maxHealth;
  }

  Weapon buildWeaponByType(int type){
    switch(type){
      case AttackType.Bow:
        return buildWeaponBow();
      case AttackType.Unarmed:
        return buildWeaponUnarmed();
      case AttackType.Assault_Rifle:
        return buildWeaponAssaultRifle();
      case AttackType.Rifle:
        return buildWeaponRifle();
      case AttackType.Handgun:
        return buildWeaponHandgun();
      case AttackType.Blade:
        return buildWeaponBlade();
      case AttackType.Fireball:
        return buildWeaponFireball();
      case AttackType.Baseball_Bat:
        return buildWeaponBaseballBat();
      case AttackType.Fireball:
        return buildWeaponFireball();
      case AttackType.Staff:
        return buildWeaponStaff();
      case AttackType.Crossbow:
        return buildWeaponCrossBow();
      case AttackType.Revolver:
        return buildWeaponRevolver();
      case AttackType.Shotgun:
        return buildWeaponShotgun();
      default:
        throw Exception("could not build weapon of type $type");
    }
  }

  void onWeaponPurchased(Player player, Weapon weapon){
    player.weapon = weapon;
     player.writePlayerWeaponType();
     player.writePlayerWeaponCapacity();
     player.writePlayerWeaponRounds();
  }

  @override
  void customOnPlayerRequestPurchaseWeapon(Player player, int type) {
    if (timer == 0) return;

    final cost = mapAttackTypeToCost(type);
    if (cost > player.points) return;

    player.points -= cost;

    player.writePlayerEvent(PlayerEvent.Item_Equipped);
    player.writeByte(type);

    onWeaponPurchased(player, buildWeaponByType(type));
  }

  @override
  int get gameType => GameType.Waves;
}