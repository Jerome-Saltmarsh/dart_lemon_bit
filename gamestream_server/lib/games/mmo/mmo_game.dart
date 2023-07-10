
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/games/mmo/mmo_npc.dart';

import 'mmo_player.dart';

class MmoGame extends IsometricGame<MmoPlayer> {

  late MMONpc npcGuard;

  MmoGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Mmo) {

    characters.add(MMONpc(
      characterType: CharacterType.Template,
      x: 900,
      y: 1100,
      z: 25,
      health: 50,
      team: MmoTeam.Human,
      weaponType: WeaponType.Handgun,
      weaponDamage: 1,
      weaponRange: 200,
      weaponCooldown: 20,
      interact: (player) {
        player.talk("Hello there");
      }
    ));

    npcGuard = MMONpc(
      characterType: CharacterType.Template,
      x: 800,
      y: 1000,
      z: 25,
      health: 200,
      weaponType: WeaponType.Machine_Gun,
      weaponRange: 200,
      weaponDamage: 1,
      weaponCooldown: 5,
      team: MmoTeam.Human,
    );

    characters.add(npcGuard);

    characters.add(IsometricZombie(
        team: MmoTeam.Alien,
        game: this,
        x: 50,
        y: 50,
        z: 24,
        health: 5,
        weaponDamage: 1,
    ));

    characters.add(
        IsometricZombie(
            team: MmoTeam.Alien,
            game: this,
            x: 80,
            y: 50,
            z: 24,
            health: 5,
            weaponDamage: 1,
        )
    );
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target is IsometricZombie){
       addJob(seconds: 30, action: () {
         setCharacterStateSpawning(target);
       });
    }
  }

  @override
  MmoPlayer buildPlayer() => MmoPlayer(game: this, itemLength: 6)
    ..x = 880
    ..y = 1100
    ..z = 50
    ..team = MmoTeam.Human
    ..setDestinationToCurrentPosition();

  @override
  int get maxPlayers => 64;
}