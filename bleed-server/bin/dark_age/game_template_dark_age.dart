

import 'package:lemon_math/library.dart';
import '../classes/library.dart';
import '../common/library.dart';
import 'dark_age_universe.dart';

abstract class GameDarkAgeTemplate extends Game {
  late DarkAgeUniverse universe;

  GameDarkAgeTemplate(Scene scene) : super(scene);


  @override
  void setHourMinutes(int hour, int minutes){
    universe.time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
  }

  @override
  int getTime() => universe.time;

  @override
  void update(){
    updateInternal();
  }

  void updateInternal(){

  }

  @override
  void onKilled(dynamic target, dynamic src){
    if (src is Player){
      if (target is AI){
        src.gainExperience(1);
      }
    }
  }

  @override
  Player spawnPlayer() {
    final player = Player(
      game: this,
      weapon: Weapon(type: WeaponType.Unarmed, damage: 1),
      team: 1,
    );

    player.indexZ = 1;
    player.indexColumn = 19;
    player.indexRow = 23;
    player.x += giveOrTake(5);
    player.y += giveOrTake(5);
    // moveCharacterToGridNode(player, GridNodeType.Player_Spawn);
    player.weapons.add(Weapon(type: WeaponType.Sword, damage: 2));
    player.weapons.add(Weapon(type: WeaponType.Bow, damage: 2));
    player.writePlayerWeapons();
    return player;
  }

  @override
  bool get full => false;

  @override
  void onPlayerDeath(Player player) {
    // revive(player);
  }

  void addNpcGuardBow({required double x, required double y, double z = 24}){
    addNpc(
      name: "Guard",
      x: x,
      y: y,
      z: z,
      head: HeadType.Rogues_Hood,
      armour: ArmourType.shirtBlue,
      pants: PantsType.green,
      weaponType: WeaponType.Bow,
      weaponDamage: 3,
    );
  }
}