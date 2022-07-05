import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/deck_card.dart';
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:lemon_watch/watch.dart';
import '../events/on_changed_player_weapon.dart';
import 'vector3.dart';
import 'package:lemon_math/library.dart';

class Player extends Vector3 {
  var angle = 0.0;
  var mouseAngle = 0.0;
  var score = 0;
  var team = 0;
  var abilityRange = 0.0;
  var abilityRadius = 0.0;
  var maxHealth = 0.0;
  var tile = Tile.Grass;
  var attackRange = 0.0;
  final selectCharacterRequired = Watch(false);
  final abilityTarget = Vector2(0, 0);
  final storeVisible = Watch(false);
  final attackTarget = Vector3();
  final mouseTargetName = Watch<String?>(null);
  final mouseTargetHealth = Watch(0.0);
  final weaponType = Watch(WeaponType.Unarmed, onChanged: onChangedPlayerWeapon);
  final weaponDamage = Watch(0);
  final armourType = Watch(ArmourType.tunicPadded);
  final headType = Watch(HeadType.None);
  final pantsType = Watch(PantsType.white);
  final equippedLevel = Watch(0);
  final characterType = Watch(CharacterType.Human);
  final health = Watch(0.0);
  final experience = Watch(0.0);
  final level = Watch(1);
  final skillPoints = Watch(0);
  final message = Watch("");
  final state = Watch(CharacterState.Idle);
  final alive = Watch(true);
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

  // int get indexZ => z ~/ 24;
  // int get indexRow => convertWorldToRow(x, y);
  // int get indexColumn => convertWorldToColumn(x, y);

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

  Player() {
    wood.onChanged(_onResourcesChanged);
    gold.onChanged(_onResourcesChanged);
    stone.onChanged(_onResourcesChanged);
  }

  void _onResourcesChanged(int value){
    _updateCanAffords();
  }

  void _updateCanAffords() {
    canAffordUpgradePickaxe.value = canAfford(TechType.Pickaxe);
    canAffordUpgradeSword.value = canAfford(TechType.Sword);
    canAffordUpgradeBow.value = canAfford(TechType.Bow);
    canAffordUpgradeAxe.value = canAfford(TechType.Axe);
    canAffordUpgradeHammer.value = canAfford(TechType.Hammer);
    canAffordUpgradeBag.value = canAfford(TechType.Bag);
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
  bool get isHuman => characterType.value == CharacterType.Human;
}
