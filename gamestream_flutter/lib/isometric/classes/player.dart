import 'package:bleed_common/library.dart';
import 'package:bleed_common/quest.dart';
import 'package:gamestream_flutter/isometric/classes/deck_card.dart';
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_game_dialog.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_map_x.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_player_alive.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_player_designed.dart';
import 'package:gamestream_flutter/isometric/events/on_quests_in_progress_changed.dart';
import 'package:lemon_watch/watch.dart';

import '../events/on_changed_npc_talk.dart';
import '../events/on_changed_player_state.dart';
import '../events/on_changed_player_weapon.dart';
import 'vector3.dart';

class Player extends Vector3 {
  final target = Vector3();
  final questAdded = Watch(false);
  var gameDialog = Watch<GameDialog?>(null, onChanged: onChangedGameDialog);
  var angle = 0.0;
  var mouseAngle = 0.0;
  var team = 0;
  var abilityRange = 0.0;
  var abilityRadius = 0.0;
  var maxHealth = 0.0;
  var attackRange = 0.0;
  final mapTile = Watch(0, onChanged: onMapTileChanged);
  var interactingNpcName = Watch<String?>(null, onChanged: onChangedNpcTalk);
  var npcTalk = Watch<String?>(null, onChanged: onChangedNpcTalk);
  var npcTalkOptions = Watch<List<String>>([]);
  final abilityTarget = Vector3();
  final attackTarget = Vector3();
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetHealth = Watch(0.0);
  final weaponDamage = Watch(0);
  final weaponType = Watch(WeaponType.Unarmed, onChanged: onChangedPlayerWeapon);
  final armourType = Watch(ArmourType.tunicPadded);
  final headType = Watch(HeadType.None);
  final pantsType = Watch(PantsType.white);
  final equippedLevel = Watch(0);
  final health = Watch(0.0);
  final designed = Watch(true, onChanged: onChangedPlayerDesigned);
  final experience = Watch(0.0);
  final level = Watch(1);
  final skillPoints = Watch(0);
  final message = Watch("");
  final state = Watch(CharacterState.Idle, onChanged: onChangedPlayerState);
  final alive = Watch(true, onChanged: onChangedPlayerAlive);
  final magic = Watch(0.0);
  final maxMagic = Watch(0.0);
  final wood = Watch(0);
  final stone = Watch(0);
  final gold = Watch(0);
  final levelPickaxe = Watch(0);
  final levelSword = Watch(0);
  final levelBow = Watch(0);
  final levelAxe = Watch(0);
  final levelHammer = Watch(0);
  final levelBag = Watch(0);
  final cardChoices = Watch<List<CardType>>([]);
  final deck = Watch<List<DeckCard>>([]);
  final deckActiveCardIndex = Watch(-1);
  final deckActiveCardRange = Watch(0.0);
  final deckActiveCardRadius = Watch(0.0);
  final questsInProgress = Watch<List<Quest>>([], onChanged: onQuestsInProgressChanged);
  final questsCompleted = Watch<List<Quest>>([]);

  final canAffordUpgradePickaxe = Watch(false);
  final canAffordUpgradeSword = Watch(false);
  final canAffordUpgradeBow = Watch(false);
  final canAffordUpgradeAxe = Watch(false);
  final canAffordUpgradeHammer = Watch(false);
  final canAffordUpgradeBag = Watch(false);
  final canAffordPalisade = Watch(false);
  final weapons = Watch(<Weapon>[]);
  final weapon = Watch<Weapon>(
      Weapon(
        type: WeaponType.Unarmed,
        damage: 1,
        uuid: "-1",
      )
  );

  Watch<bool> getCanAffordWatch(int type){
    switch (type){
      case TechType.Pickaxe:
        return canAffordUpgradePickaxe;
      case TechType.Sword:
        return canAffordUpgradeSword;
      case TechType.Axe:
        return canAffordUpgradeAxe;
      case TechType.Bow:
        return canAffordUpgradeBow;
      case TechType.Hammer:
        return canAffordUpgradeHammer;
      case TechType.Bag:
        return canAffordUpgradeBag;
    }
    throw Exception('getCanAffordWatch error, $type has no watch');
  }

  bool canAfford(int type) {
    final cost = TechType.getCost(type, getTechTypeLevel(type));
    return
      cost != null &&
          wood.value >= cost.wood &&
          stone.value >= cost.stone &&
          gold.value >= cost.gold
    ;
  }

  Watch<int> getTechLevelWatch(int type){
    switch(type){
      case TechType.Pickaxe:
        return levelPickaxe;
      case TechType.Sword:
        return levelSword;
      case TechType.Bow:
        return levelBow;
      case TechType.Axe:
        return levelAxe;
      case TechType.Hammer:
        return levelHammer;
      case TechType.Bag:
        return levelBag;
      default:
        throw Exception("cannot get tech type level. type: $type");
    }
  }

  int getTechTypeLevel(int type){
    return getTechLevelWatch(type).value;
  }

  // Properties
  bool get dead => !alive.value;
}
