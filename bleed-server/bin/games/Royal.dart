import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/give_or_take.dart';

import '../classes/Character.dart';
import '../classes/Crate.dart';
import '../classes/Game.dart';
import '../classes/Item.dart';
import '../classes/Npc.dart';
import '../classes/Player.dart';
import '../classes/Weapon.dart';
import '../common/CharacterType.dart';
import '../common/GameEventType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/ItemType.dart';
import '../common/WeaponType.dart';
import '../functions/withinRadius.dart';
import '../instances/scenes.dart';
import '../utilities.dart';

class GameRoyal extends Game {

  final List<Player> score = [];
  final boundaryRadiusShrinkRate = 0.05;
  double boundaryRadius = 1000;
  Vector2 boundaryCenter = Vector2(0, 0);

  final time = calculateTime(hour: 9);

  get _randomSpawnRadius => 500;
  double get randomX => boundaryCenter.x + giveOrTake(_randomSpawnRadius);
  double get randomY => boundaryCenter.y + giveOrTake(_randomSpawnRadius);

  GameRoyal() : super(scenes.royal, gameType: GameType.BATTLE_ROYAL) {
    status = GameStatus.Awaiting_Players;
    teamSize = 1;
    numberOfTeams = 2;
    boundaryCenter = getSceneCenter();

    for (Character zombie in zombies) {
      zombie.team = 1;
    }

    for (int i = 0; i < 10; i++) {
      final crate = Crate(
          x: randomX,
          y: randomY,
      );
      crates.add(crate);
      cratesDirty = true;
    }

    for (int i = 0; i < 5; i++){
      items.add(Item(type: ItemType.Handgun, x:  randomX, y: randomY));
    }
    for (int i = 0; i < 5; i++){
      items.add(Item(type: ItemType.Shotgun, x:  randomX, y: randomY));
    }
    for (int i = 0; i < 5; i++){
      items.add(Item(type: ItemType.Armour, x:  randomX, y: randomY));
    }
    for (int i = 0; i < 5; i++){
      items.add(Item(type: ItemType.Health, x:  randomX, y: randomY));
    }

    sortVertically(items);
    sortVertically(crates);
  }

  int get playersRequired => teamSize * numberOfTeams;

  @override
  void onNpcKilled(Npc npc, Character src){
     items.add(Item(type: ItemType.Orb_Emerald, x: npc.x, y: npc.y));
  }

  @override
  bool onPlayerItemCollision(Player player, Item item){

    final itemWeaponType = item.type.weaponType;
    if (itemWeaponType != null){
      dispatch(GameEventType.Item_Acquired, item.x, item.y);
      final weaponIndex = getIndexOfWeaponType(player, itemWeaponType);
      if (weaponIndex == -1){
        player.weapons.add(_buildWeapon(itemWeaponType));
        player.equippedIndex = getIndexOfWeaponType(player, itemWeaponType);
        final weaponType = item.type.weaponType;
        if (weaponType != null) {
          player.equip(weaponType);
        }
      } else {
        final weapon = player.weapons[weaponIndex];
        weapon.rounds += _getWeaponTypeRounds(itemWeaponType);
      }
      return true;
    }

    if (item.type == ItemType.Orb_Emerald){
      player.orbs.emerald++;
    }
    if (item.type == ItemType.Orb_Topaz){
      player.orbs.topaz++;
    }
    if (item.type == ItemType.Orb_Ruby){
      player.orbs.ruby++;
    }

    if (item.type == ItemType.Armour) {
      player.armour = player.maxArmour;
    }

    if (item.type == ItemType.Health){
      player.health += 10;
    }

    return true;
  }

  Weapon _buildWeapon(WeaponType type){
    return Weapon(
        type: type,
        damage: _getWeaponTypeDamage(type),
        capacity: _getWeaponTypeCapacity(type),
        rounds: _getWeaponTypeRounds(type),
    );
  }

  int _getWeaponTypeDamage(WeaponType type){
    switch(type){
      case WeaponType.Unarmed:
        return 0;
      case WeaponType.HandGun:
        return 5;
      case WeaponType.Shotgun:
        return 20;
      case WeaponType.SniperRifle:
        return 20;
      case WeaponType.AssaultRifle:
        return 4;
    }
  }

  int _getWeaponTypeRounds(WeaponType type){
    switch(type){
      case WeaponType.Unarmed:
        return 0;
      case WeaponType.HandGun:
        return 10;
      case WeaponType.Shotgun:
        return 8;
      case WeaponType.SniperRifle:
        return 5;
      case WeaponType.AssaultRifle:
        return 15;
    }
  }

  int _getWeaponTypeCapacity(WeaponType type){
    switch(type){
      case WeaponType.Unarmed:
        return 0;
      case WeaponType.HandGun:
        return 50;
      case WeaponType.Shotgun:
        return 20;
      case WeaponType.SniperRifle:
        return 12;
      case WeaponType.AssaultRifle:
        return 120;
    }
  }

  Player playerJoin() {
    if (status != GameStatus.Awaiting_Players) {
      throw Exception("Game already started");
    }
    Vector2 spawnPoint = getNextSpawnPoint();
    final Player player = Player(
      game: this,
      x: spawnPoint.x,
      y: spawnPoint.y,
      team: -1,
      type: CharacterType.Human,
    );
    if (players.length >= playersRequired) {
      status = GameStatus.Counting_Down;
    }
    return player;
  }

  @override
  void onPlayerDisconnected(Player player) {
    if (inProgress){
      onPlayerDeath(player);
    } else if (countingDown){
      // status = GameStatus.Awaiting_Players;
      // _countDownFrame = _totalCountdownFrames;
    }
  }

  @override
  void onPlayerDeath(Player player) {
    score.add(player);
    if (numberOfAlivePlayers == 1) {
      status = GameStatus.Finished;
    }
  }

  @override
  int getTime() {
    return time;
  }

  @override
  void update(){
    boundaryRadius -= boundaryRadiusShrinkRate;
    _killPlayersOutsideBoundary();

    for (Player player in players) {
      for (int i = 0; i < crates.length; i++) {
        final crate = crates[i];
        if (!withinRadius(player, crate, 30)) continue;
        final index = getIndexOfWeaponType(player, WeaponType.HandGun);
        if (index >= 0) continue;
        player.weapons.add(Weapon(
          type: WeaponType.HandGun,
          damage: 5,
          capacity: 12,
        ));
        player.weaponsDirty = true;
        crates.removeAt(i);
        cratesDirty = true;
        i--;
      }
    }

    return;
  }

  void _killPlayersOutsideBoundary() {
    for (Player player in players) {
      if (player.dead) continue;
      if (withinDeathBoundary(player)) continue;
      setCharacterStateDead(player);
    }
  }

  bool withinDeathBoundary(Vector2 position){
    return withinRadius(position, boundaryCenter, boundaryRadius);
  }
}



