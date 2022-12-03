
import 'package:bleed_server/gamestream.dart';
import 'package:lemon_math/library.dart';

import '../functions/move_player_to_crystal.dart';
import 'dark_age_environment.dart';

class GameDarkAge extends Game {
  final DarkAgeEnvironment environment;

  var _underground = false;

  bool get underground => _underground;

  set underground(bool value){
     if (value == _underground) return;
     _underground = value;
     for (final player in players) {
       player.writeWeather();
     }
  }

  void toggleUnderground(){
     underground = !underground;
  }

  @override
  bool get customPropMapVisible => true;

  @override
  int get gameType => GameType.Dark_Age;

  GameDarkAge(Scene scene, this.environment) : super(scene) {
    triggerSpawnPoints();
  }

  @override
  void customOnHitApplied(Character src, Collider target) {
     if (src is AI) {
        if (randomBool()) {
          src.aiMode = AIMode.Idle;
          src.aiMode = randomInt(AI.Frames_Between_AI_Mode_Min, AI.Frames_Between_AI_Mode_Max);
        }
     }
     if (target is AI) {
       if (random.nextDouble() > 0.2){
         target.aiMode = AIMode.Pursue;
         target.aiModeNext = AI.Frames_Between_AI_Mode_Max;
       } else {
         target.aiMode = AIMode.Evade;
         target.aiModeNext = AI.Frames_Between_AI_Mode_Max;
       }
     }
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
     if (target is AI){
        if (src is Player) {
           src.experience += 1;
        }
        if (random.nextDouble() < 0.25){
          spawnRandomItemAtPosition(target, timer: 2000);
        }
     }
  }

  void spawnRandomItemAtPosition(Position3 position, {int timer = 0}){
       spawnGameObjectItem(
           x: position.x,
           y: position.y,
           z: position.z,
           type: getRandomItemType(),
           timer: timer,
       );
  }

  int getRandomItemType() => randomItem(const [
    ItemType.Weapon_Ranged_Shotgun,
    ItemType.Body_Tunic_Padded,
    ItemType.Body_Shirt_Blue,
    ItemType.Body_Shirt_Cyan,
    ItemType.Resource_Wood,
    ItemType.Resource_Gold,
    ItemType.Resource_Crystal,
    ItemType.Resource_Stone,
  ]);

  @override
  void customOnCharacterSpawned(Character character){
    if (character is Player){
      dispatchV3(GameEventType.Player_Spawned, character);
    }
  }

  @override
  void customPlayerWrite(Player player) {
     player.writeGameTime(environment.time.time);
  }

  @override
  void customOnCollisionBetweenColliders(Collider a, Collider b) {

  }

  @override
  void setHourMinutes(int hour, int minutes){
    environment.time.time = (hour * secondsPerHour) + (minutes * secondsPerMinute);
    environment.updateShade();
    playersWriteWeather();
  }

  @override
  void customOnPlayerRevived(Player player){
      changeGame(player, engine.findGameDarkAge());
      movePlayerToCrystal(player);
  }

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        weaponType: ItemType.Weapon_Handgun_Flint_Lock_Old,
        team: 1,
    );

    return player;
  }

  void addNpcGuardBow({required int row, required int column, int z = 1}){
    addNpc(
      name: "Guard",
      row: row,
      column: column,
      z: 1,
      headType: ItemType.Head_Wizards_Hat,
      armour: ItemType.Body_Tunic_Padded,
      pants: ItemType.Legs_Brown,
      weaponType: ItemType.Weapon_Ranged_Bow,
      team: 1
    );
  }

  @override
  void customUpdate() {
    // TODO: implement customUpdate
  }
}