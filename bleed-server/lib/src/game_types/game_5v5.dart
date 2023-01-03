
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/dark_age/dark_age_environment.dart';

class Game5v5 extends Game {

  static const Player_Per_Team = 1;
  static const Total_Players = Player_Per_Team * 2;

  var gameStatus = GameStatus.Waiting_For_Players;
  var spawnPoint1 = 0;
  var spawnPoint2 = 1;

  final env = DarkAgeEnvironment();


  bool get started => gameStatus == GameStatus.Playing;

  static const Store_Items = [
     ItemType.Weapon_Handgun_Glock,
     ItemType.Weapon_Smg_Mp5,
  ];

  Game5v5({required super.scene}) : super(
      time: DarkAgeTime(),
      environment: DarkAgeEnvironment(),
      gameType: GameType.FiveVFive,
  ) {
    if (scene.spawnPointsPlayers.length >= 2) {
      spawnPoint1 = scene.spawnPointsPlayers[0];
      spawnPoint2 = scene.spawnPointsPlayers[1];
    }
  }

  @override
  int get gameType => GameType.FiveVFive;

  @override
  void customOnPlayerJoined(Player player) {
    assert(!started);

    if (players.length == Player_Per_Team * 2) {
      start();
    } else {
      player.writeGameStatus(GameStatus.Waiting_For_Players);
    }
  }

  void start(){
    assert(players.length == Total_Players);
    gameStatus = GameStatus.Playing;

    for (var i = 0; i < Player_Per_Team; i++){
      final player = players[i];
      player.team = 1;
      moveToIndex(player, spawnPoint1);
    }
    for (var i = Player_Per_Team; i < Total_Players; i++){
      final player = players[i];
      player.team = 2;
      moveToIndex(player, spawnPoint2);
    }
    playersWriteGameStatus(GameStatus.Playing);

    for (final player in players){
      player.storeItems = Store_Items;
      player.writeStoreItems();
      player.interactMode = InteractMode.Trading;
    }
  }

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
     if (target is Player){
        onPlayerKilled(target);
     }
  }

  void onPlayerKilled(Player player){

  }

  @override
  void revive(Player player) {
     player.writeError('cannot revive');
  }
}