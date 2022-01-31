import 'package:bleed_client/classes/Ability.dart';
import 'package:bleed_client/classes/Weapon.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/CharacterType.dart';
import 'package:bleed_client/common/GameStatus.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'classes.dart';

class GameState {
  final _Player player = _Player();
  final Watch<GameStatus> status = Watch(GameStatus.Awaiting_Players);
  final TextEditingController textEditingControllerMessage = TextEditingController();
  FocusNode textFieldMessage = FocusNode();
  final CharacterController characterController = CharacterController();
  bool panningCamera = false;
  final KeyMap keyMap = KeyMap();
  final Watch<bool> textMode = Watch(false);

  final List<String> letsGo = [
    "Come on!",
    "Let's go!",
    'Follow me!',
  ];

  final List<String> greetings = [
    'Hello',
    'Hi',
    'Greetings',
  ];

  final List<String> waitASecond = ['Wait a second', 'Just a moment'];
}

class _Player {
  int id = -1;
  double x = -1;
  double y = -1;
  final Watch<String> uuid = Watch("");
  final Watch<WeaponType> weaponType = Watch(WeaponType.Unarmed);
  final List<Weapon> weapons = [];
  final Watch<int> weaponRounds = Watch(0);
  final Watch<int> weaponCapacity = Watch(0);
  Vector2 abilityTarget = Vector2(0, 0);
  double abilityRange = 0;
  double abilityRadius = 0;
  final Watch<CharacterType> characterType = Watch(CharacterType.Human);
  int squad = -1;
  Watch<double> health = Watch(0.0);
  double maxHealth = 0;
  Tile tile = Tile.Grass;
  Watch<int> experience = Watch(0);
  Watch<int> level = Watch(1);
  Watch<int> skillPoints = Watch(1);
  Watch<int> nextLevelExperience = Watch(1);
  Watch<double> experiencePercentage = Watch(0);
  Watch<String> message = Watch("");
  Watch<CharacterState> state = Watch(CharacterState.Idle);
  Watch<bool> alive = Watch(true);
  final _Unlocked unlocked = _Unlocked();
  final Watch<AbilityType> ability = Watch(AbilityType.None);

  final Watch<double> magic = Watch(0);
  final Watch<double> maxMagic = Watch(0);

  final Ability ability1 = Ability(1);
  final Ability ability2 = Ability(2);
  final Ability ability3 = Ability(3);
  final Ability ability4 = Ability(4);

  _Player() {
    magic.onChanged((double value) {
      ability1.canAfford.value = value >= ability1.magicCost.value;
      ability2.canAfford.value = value >= ability2.magicCost.value;
      ability3.canAfford.value = value >= ability3.magicCost.value;
      ability4.canAfford.value = value >= ability4.magicCost.value;
    });

    ability.onChanged((AbilityType abilityType) {
      ability1.selected.value = ability1.type.value == abilityType;
      ability2.selected.value = ability2.type.value == abilityType;
      ability3.selected.value = ability3.type.value == abilityType;
      ability4.selected.value = ability4.type.value == abilityType;
    });
  }

  bool get dead => !alive.value;

  // bool get canPurchase => tile == Tile.PlayerSpawn;
  bool get canPurchase => false;

  double attackRange = 0;
  int team = 0;
  bool get isHuman => characterType.value == CharacterType.Human;
  Vector2 attackTarget = Vector2(0, 0);
}

class _Unlocked {
  bool get handgun => modules.game.state.player.weaponUnlocked(WeaponType.HandGun);

  bool get shotgun => modules.game.state.player.weaponUnlocked(WeaponType.Shotgun);
}

extension PlayerExtentions on _Player {
  bool weaponUnlocked(WeaponType weaponType) {
    for (Weapon weapon in weapons) {
      if (weapon.type == weaponType) return true;
    }
    return false;
  }

  bool get shotgunUnlocked {
    for (Weapon weapon in weapons) {
      if (weapon.type == WeaponType.Shotgun) return true;
    }
    return false;
  }
}

