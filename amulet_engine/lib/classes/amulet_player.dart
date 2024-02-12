
import 'dart:math';

import '../packages/isomeric_engine.dart';
import '../mixins/src.dart';
import '../packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import '../packages/isometric_engine/packages/common/src/amulet/quests/quest_tutorials.dart';
import 'amulet.dart';
import 'amulet_fiend.dart';
import 'amulet_game.dart';
import 'amulet_gameobject.dart';
import 'amulet_npc.dart';
import 'games/amulet_game_tutorial.dart';
import 'talk_option.dart';



class AmuletPlayer extends IsometricPlayer with
    Equipped,
    Skilled,
    Magic
{
  static const Data_Key_Dead_Count = 'dead';

  var questTutorial = QuestTutorial.values.first;
  var questMain = QuestMain.values.first;
  var baseHealth = 10;
  var baseMagic = 10;
  var baseRegenMagic = 1;
  var baseRegenHealth = 1;
  var baseRunSpeed = 1.0;

  var castePositionX = 0.0;
  var castePositionY = 0.0;
  var castePositionZ = 0.0;

  var admin = false;
  var previousCameraTarget = false;
  var equipmentDirty = true;

  var cacheRegenMagic = 0;
  var cacheRegenHealth = 0;
  var cacheRunSpeed = 0.0;
  var cacheWeaponDamageMin = 0;
  var cacheWeaponDamageMax = 0;
  var cacheWeaponRange = 0;

  var npcText = '';
  var npcName = '';
  var npcOptions = <TalkOption>[];
  var flags = <dynamic>[];

  var flaskAmount = 0;
  static const flaskCapacity = 25;

  final sceneShrinesUsed = <AmuletScene, List<int>> {};

  Function? onInteractionOver;
  Position? cameraTarget;
  AmuletGame amuletGame;
  SlotType? activeSlotType;

  AmuletPlayer({
    required this.amuletGame,
    required int itemLength,
    required super.x,
    required super.y,
    required super.z,
  }) : super(game: amuletGame, health: 10, team: TeamType.Good) {
    respawnDurationTotal = -1;
    controlsCanTargetEnemies = true;
    characterType = CharacterType.Human;
    hurtable = false;
    hurtStateBusy = false;
    regainFullHealth();
    regainFullMagic();
    active = false;
    equipmentDirty = true;
    setControlsEnabled(true);
    writeWorldMapBytes();
    writeWorldMapLocations();
    writeInteracting();
    writeGender();
    writePlayerComplexion();
    setFlaskAmount(flaskCapacity);
  }

  @override
  set magic(int value) {
    value = value.clamp(0, maxMagic);
    super.magic = value;
    writePlayerMagic();
  }

  // int get deathCount => data.tryGetInt(Data_Key_Dead_Count) ?? 0;

  // set deathCount(int value) => data.setInt(Data_Key_Dead_Count, value);

  int get proficiencySword {
    var total = 0;
    total += equippedWeapon?.talentSword ?? 0;
    total += equippedHelm?.talentSword ?? 0;
    total += equippedArmor?.talentSword ?? 0;
    total += equippedShoes?.talentSword ?? 0;
    return total;
  }

  int get proficiencyStaff {
    var total = 0;
    total += equippedWeapon?.talentStaff ?? 0;
    total += equippedHelm?.talentStaff ?? 0;
    total += equippedArmor?.talentStaff ?? 0;
    total += equippedShoes?.talentStaff ?? 0;
    return total;
  }

  int get proficiencyBow {
    var total = 0;
    total += equippedWeapon?.talentBow ?? 0;
    total += equippedHelm?.talentBow ?? 0;
    total += equippedArmor?.talentBow ?? 0;
    total += equippedShoes?.talentBow ?? 0;
    return total;
  }

  int get proficiencyCaste {
    var total = 0;
    total += equippedWeapon?.talentCaste ?? 0;
    total += equippedHelm?.talentCaste ?? 0;
    total += equippedArmor?.talentCaste ?? 0;
    total += equippedShoes?.talentCaste ?? 0;
    return total;
  }

  void setQuestMain (QuestMain value){
    this.questMain = value;
    writeQuestMain(value);
  }

  // @override
  // set aimTarget(Collider? value) {
  //   if (
  //   noWeaponEquipped &&
  //       value is GameObject &&
  //       value.hitable
  //   ){
  //     return;
  //   }
  //   super.aimTarget = value;
  // }

  bool get noWeaponEquipped => equippedWeapon == null;

  // int get randomWeaponDamage {
  //   final weapon = equippedWeapon;
  //   if (weapon == null){
  //     return 0;
  //   }
  //   return randomInt(weapon.damageMin ?? 0, weapon.damageMax ?? 0);
  // }

  Amulet get amulet => amuletGame.amulet;

  @override
  int get weaponType => equippedWeapon?.subType ?? WeaponType.Unarmed;

  @override
  int get attackDamage => getSkillTypeDamage(skillActive);

  @override
  double get attackRange => getSkillTypeRange(skillActive);

  @override
  int get helmType => equippedHelm?.subType ?? HelmType.None;

  @override
  int get maxHealth {
    var health = baseHealth;
    health += equippedWeapon?.maxHealth ?? 0;
    health += equippedHelm?.maxHealth ?? 0;
    health += equippedArmor?.maxHealth ?? 0;
    health += equippedShoes?.maxHealth ?? 0;
    return health;
  }

  @override
  int get maxMagic {
    var amount = baseMagic;
    amount += equippedWeapon?.maxMagic ?? 0;
    amount += equippedHelm?.maxMagic ?? 0;
    amount += equippedArmor?.maxMagic ?? 0;
    amount += equippedShoes?.maxMagic ?? 0;
    return amount;
  }

  @override
  set target(Position? value){
    if (super.target == value) {
      return;
    }

    if (interacting) {
      endInteraction();
    }
    super.target = value;
  }

  set interacting(bool value){
    if (super.interacting == value) {
      return;
    }
    super.interacting = value;

    if (!value){
      onInteractionOver?.call();
      onInteractionOver = null;
      cameraTarget = null;
    }

    writeInteracting();
  }

  // int get weaponDamageMin {
  //   return equippedWeapon?.damageMin ?? 0;
  // }
  //
  // int get weaponDamageMax {
  //   return equippedWeapon?.damageMax ?? 0;
  // }

  int get regenMagic {
    var total = baseRegenMagic;
    total += equippedWeapon?.regenMagic ?? 0;
    total += equippedHelm?.regenMagic ?? 0;
    total += equippedArmor?.regenMagic ?? 0;
    total += equippedShoes?.regenMagic ?? 0;
    return total;
  }

  int get regenHealth {
    var total = baseRegenHealth;
    total += equippedWeapon?.regenHealth ?? 0;
    total += equippedHelm?.regenHealth ?? 0;
    total += equippedArmor?.regenHealth ?? 0;
    total += equippedShoes?.regenHealth ?? 0;
    return total;
  }

  @override
  double get runSpeed {
    var total = baseRunSpeed;
    total += equippedWeapon?.runSpeed ?? 0;
    total += equippedHelm?.runSpeed ?? 0;
    total += equippedArmor?.runSpeed ?? 0;
    total += equippedShoes?.runSpeed ?? 0;
    return total;
  }

  @override
  void writePlayerGame() {
    cleanEquipment();
    writeCameraTarget();
    writeRegenMagic();
    writeRegenHealth();
    writeRunSpeed();
    // writeWeaponDamage();
    super.writePlayerGame();
  }

  void writeRegenMagic() {
    if (cacheRegenMagic == regenMagic) return;
    cacheRegenMagic = regenMagic;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Regen_Magic);
    writeUInt16(regenMagic);
  }

  void writeRegenHealth() {
    if (cacheRegenHealth == regenHealth) return;
    cacheRegenHealth = regenHealth;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Regen_Health);
    writeUInt16(regenHealth);
  }

  void writeRunSpeed() {
    if (cacheRunSpeed == runSpeed) return;
    cacheRunSpeed = runSpeed;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Run_Speed);
    writeUInt16((runSpeed * 10).toInt());
  }

  // void writeWeaponDamage() {
  //   if (
  //     cacheWeaponDamageMin == weaponDamageMin &&
  //     cacheWeaponDamageMax == weaponDamageMax &&
  //     cacheWeaponRange == attackRange
  //   ) return;
  //   cacheWeaponDamageMin = cacheWeaponDamageMin;
  //   cacheWeaponDamageMax = cacheWeaponDamageMax;
  //   writeByte(NetworkResponse.Amulet);
  //   writeByte(NetworkResponseAmulet.Player_Weapon_Damage);
  //   writeUInt16(weaponDamageMin);
  //   writeUInt16(weaponDamageMax);
  //   writeUInt16(attackRange.toInt());
  // }

  void writeDebug() {
    if (!debugging) return;

    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Debug);
    var total = 0;
    final characters = game.characters;
    for (final character in characters) {
      if (character is AmuletPlayer && onScreenPosition(character)) {
        total++;
      }
    }
    writeUInt16(total);

    for (final character in characters) {
      if (character is AmuletPlayer && onScreenPosition(character)) {
         writeIsometricPosition(character);
         writeString(character.name);
      }
    }
  }

  bool acquireAmuletItem(AmuletItem amuletItem){
    if (deadOrBusy) {
      return false;
    }
    setDestinationToCurrentPosition();
    clearPath();
    equipAmuletItem(value: amuletItem);
    return true;
  }

  @override
  int getTargetAction(Position? value){
    if (value == null) {
      return TargetAction.Run;
    }
    if (value is GameObject) {
      if (value.interactable) {
        return TargetAction.Talk;
      }
      if (value.collectable) {
        return TargetAction.Collect;
      }
      return TargetAction.Run;
    }

    if (isAlly(value)) {
      if (value is AmuletNpc && value.interact != null) {
        return TargetAction.Talk;
      }
    }
    if (isEnemy(value)) {
      return TargetAction.Attack;
    }
    return TargetAction.Run;
  }

  void talk(
      Collider speaker,
      String text, {
        List<TalkOption>? options,
        Function? onInteractionOver,
      }) {

    cameraTarget = speaker;
    this.onInteractionOver = onInteractionOver;

    if (text.isNotEmpty){
      interacting = true;
    }
     npcText = text;
     npcName = speaker.name;
     if (options != null){
       this.npcOptions = options;
     } else {
       this.npcOptions.clear();
     }
     writeNpcTalk();
  }

  void endInteraction() {
    if (!interacting) return;
    interacting = false;
    npcName = '';
    npcText = '';
    npcOptions.clear();
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.End_Interaction);
    clearTarget();
  }

  void spawnAmuletItem(AmuletItem item){
    const spawnDistance = 40.0;
    final spawnAngle = randomAngle();
    amuletGame.spawnAmuletItem(
      x: x + adj(spawnAngle, spawnDistance),
      y: y + opp(spawnAngle, spawnDistance),
      z: z,
      item: item,
    );
  }

  // void deactivateSlotType() => setActiveSlotType(null);

  // void setActiveSlotType(SlotType? value) {
  //   activeSlotType = value;
  //   writeByte(NetworkResponse.Amulet);
  //   writeByte(NetworkResponseAmulet.Active_Slot_Type);
  //   if (value == null) {
  //     writeFalse();
  //     return;
  //   }
  //   writeTrue();
  //   writeByte(value.index);
  // }

  void selectNpcTalkOption(int index) {
     if (index < 0 || index >= npcOptions.length){
       writeAmuletError('Invalid talk option index $index');
       return;
     }
     npcOptions[index].action(this);
  }

  void cleanEquipment(){
    if (!equipmentDirty) {
      return;
    }

    health = clamp(health, 0, maxHealth);
    weaponType = equippedWeapon?.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;
    helmType = equippedHelm?.subType ?? HelmType.None;
    armorType = equippedArmor?.subType ?? 0;
    shoeType = equippedShoes?.subType ?? ShoeType.None;
    checkAssignedSkillTypes();
    checkActiveSlotType();
    writeEquipped();
    writePlayerHealth();
    writePlayerMagic();
    writeSkillTypes();
    writeCharacteristics();
  }

  void checkAssignedSkillTypes() {

    if (!skillTypeUnlocked(skillTypeLeft)) {
      skillTypeLeft = equippedWeaponDefaultSkillType;
    }

    if (skillTypeUnlocked(skillTypeRight)) {
      return;
    }

    for (var i = SkillType.values.length - 1; i >= 0; i--) {
      final skillType = SkillType.values[i];
      if (skillTypeUnlocked(skillType)) {
        skillTypeRight = skillType;
        return;
      }
    }
    skillTypeRight = equippedWeaponDefaultSkillType;
  }

  SkillType get equippedWeaponDefaultSkillType {
    if (equippedWeaponBow) {
      return SkillType.Shoot_Arrow;
    }
    if (equippedWeaponMelee) {
      return SkillType.Strike;
    }
    return SkillType.None;
  }

  void writeEquipped(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Equipped);
    writeAmuletItem(equippedWeapon);
    writeAmuletItem(equippedHelm);
    writeAmuletItem(equippedArmor);
    writeAmuletItem(equippedShoes);
  }

  void writeAmuletItem(AmuletItem? value){
    if (value == null){
      writeInt16(-1);
    } else{
      writeInt16(value.index);
    }
  }

  void writeInteracting() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Interacting);
    writeBool(interacting);
  }

  void writePlayerItem(int index, AmuletItem? item) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Item);
    writeUInt16(index);
    if (item == null){
      writeInt16(-1);
      return;
    }
    writeInt16(item.index);
  }

  void writeNpcTalk() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Npc_Talk);
    writeString(npcName);
    writeString(npcText);
    writeByte(npcOptions.length);
    for (final option in npcOptions) {
      writeString(option.text);
    }
  }

  @override
  void setCharacterStateChanging({int duration = 15}) {
    super.setCharacterStateChanging(duration: duration);
    writePlayerEvent(PlayerEvent.Character_State_Changing);
  }

  // @override
  // void update() {
  //   super.update();
  //   updateActiveSkillTypePosition();
  // }

  void updateCastePosition() {
    final skillType = skillActive;
    final mouseDistance = getMouseDistance();
    final maxRange = getSkillTypeRange(skillType);
    if (mouseDistance <= maxRange){
      castePositionX = mouseSceneX;
      castePositionY = mouseSceneY;
      castePositionZ = mouseSceneZ;
    } else {
      final mouseAngle = getMouseAngle() + pi;
      castePositionX = x + adj(mouseAngle, maxRange);
      castePositionY = y + opp(mouseAngle, maxRange);
      castePositionZ = z;
    }
  }

  void writeActivePowerPosition() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Active_Power_Position);
    writeDouble(castePositionX);
    writeDouble(castePositionY);
    writeDouble(castePositionZ);
  }

  void equipAmuletItem({
    required AmuletItem value,
    bool force = false,
  }) {

    final currentlyEquipped = getEquippedAmuletItem(itemType: value.type);
    if (currentlyEquipped != null) {
      dropItemType(currentlyEquipped.type);
    }

    switch (value.type){
      case ItemType.Weapon:
        equippedWeapon = value;
        if (skillTypeLeft == SkillType.None){
          skillTypeLeft = equippedWeaponDefaultSkillType;
        }
        if (skillTypeRight == SkillType.None){
          skillTypeRight = equippedWeaponDefaultSkillType;
        }
        break;
      case ItemType.Helm:
        equippedHelm = value;
        break;
      case ItemType.Armor:
        equippedArmor = value;
        break;
      case ItemType.Shoes:
        equippedShoes = value;
        break;
    }

    notifyEquipmentDirty();
  }


  void notifyEquipmentDirty(){
    if (equipmentDirty) {
      return;
    }

    setCharacterStateChanging();
    equipmentDirty = true;
  }

  @override
  void reportException(Object exception) {
    writeAmuletError(exception.toString());
  }

  void writeAmuletError(String error) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Error);
    writeString(error);
  }

  void dropItemType(int itemType){
      final equippedAmuletItem = getEquippedAmuletItem(itemType: itemType);
      if (equippedAmuletItem == null){
        return;
      }

      spawnAmuletItem(equippedAmuletItem);
      switch (equippedAmuletItem.type) {
        case ItemType.Weapon:
          equippedWeapon = null;
          break;
        case ItemType.Helm:
          equippedHelm = null;
          break;
        case ItemType.Armor:
          equippedArmor = null;
          break;
        case ItemType.Shoes:
          equippedShoes = null;
          break;
      }

      writePlayerEvent(PlayerEvent.Item_Dropped);
      notifyEquipmentDirty();
  }

  AmuletItem? getEquippedAmuletItem({required int itemType}) =>
      switch (itemType){
        ItemType.Weapon => equippedWeapon,
        ItemType.Helm => equippedHelm,
        ItemType.Armor => equippedArmor,
        ItemType.Shoes => equippedShoes,
        _ => null
    };

  // @override
  // void clearAction() {
  //   super.clearAction();
  //   deactivateSlotType();
  // }

  void writeMessage(String message){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Message);
    writeString(message);
  }

  void setPosition({double? x, double? y, double? z}){
    if (x != null){
      this.x = x;
    }
    if (y != null){
      this.y = y;
    }
    if (z != null){
      this.z = z;
    }

    clearPath();
    setDestinationToCurrentPosition();
    writePlayerPositionAbsolute();
    writePlayerEvent(PlayerEvent.Player_Moved);
  }

  /// to run a piece of code only a single time
  /// the first time a flag name is entered it will return true
  /// however any time after that if the same flag name is entered
  /// the return will be false
  bool flagged(String name){
    if (flags.contains(name))
      return false;

    flags.add(name);
    return true;
  }

  void writeCameraTarget() {
    final cameraTarget = this.cameraTarget;

    if (cameraTarget == null && !previousCameraTarget){
      return;
    }

    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Camera_Target);

    if (cameraTarget == null){
      previousCameraTarget = false;
      writeBool(false);
      return;
    }

    previousCameraTarget = true;
    writeBool(true);
    writePosition(cameraTarget);
  }

  void changeGame(AmuletGame targetAmuletGame) =>
    amuletGame.amulet.playerChangeGame(
      player: this,
      target: targetAmuletGame,
    );

  void clearCameraTarget() {
    setCameraTarget(null);
  }

  void setCameraTarget(Position? target) {
    this.cameraTarget = target;
  }

  void playAudioType(AudioType audioType){
     writeByte(NetworkResponse.Amulet);
     writeByte(NetworkResponseAmulet.Play_AudioType);
     writeByte(audioType.index);
  }

  @override
  void attack() {

    if (deadInactiveOrBusy) {
      return;
    }

    if (skillActive == SkillType.None){
      return;
    }

    final performDuration = getSkillTypePerformDuration(skillActive);
    final magicCost = getSkillTypeMagicCost(skillActive);
    if (magicCost > magic) {
      writeGameError(GameError.Insufficient_Magic);
      return;
    }

    switch (skillActive.casteType) {
      case CasteType.Passive:
        throw Exception('cannot perform $skillActive.casteType == CasteType.Passive');
      case CasteType.Caste:
        setCharacterStateCasting(
          duration: performDuration
        );
        break;
      case CasteType.Bow:
        if (!equippedWeaponBow){
          writeGameError(GameError.Bow_Required);
          return;
        }
        setCharacterStateFire(
            duration: performDuration
        );
        break;
      case CasteType.Staff:
        if (!equippedWeaponStaff) {
          writeGameError(GameError.Staff_Required);
          return;
        }
        setCharacterStateStriking(
          duration: performDuration
        );
        break;
      case CasteType.Sword:
        if (!equippedWeaponSword) {
          writeGameError(GameError.Sword_Required);
          return;
        }
        setCharacterStateStriking(
          duration: performDuration
        );
        break;
    }

    magic -= magicCost;
  }

  writeHighlightAmuletItems(AmuletItem amuletItem){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Highlight_Amulet_Item);
    writeByte(amuletItem.index);
  }

  void writeClearHighlightedAmuletItem(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Highlight_Amulet_Item_Clear);
  }

  @override
  void downloadScene() {
    super.downloadScene();
    writeSceneName();
    writeOptionsSetTimeVisible(game is! AmuletGameTutorial);
    writeOptionsSetHighlightIconInventory(false);
    writeSkillsLeftRight();
    writeSkillTypes();
    writeFiendCount();
  }

  void writeSceneName() {
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Name);
    writeString(amuletGame.name);
  }

  void regainFullHealth() {
    health = maxHealth;
  }

  void regainFullMagic(){
    magic = maxMagic;
  }

  void spawnConfettiAtPosition(Position position) =>
    spawnConfetti(
      x: position.x,
      y: position.y,
      z: position.z,
    );

  void spawnConfetti({
    required double x,
    required double y,
    required double z,
  }) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Spawn_Confetti);
    writeDouble(x);
    writeDouble(y);
    writeDouble(z);
  }

  void writeElementUpgraded() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Element_Upgraded);
  }

  void writeOptionsSetTimeVisible(bool value){
    writeByte(NetworkResponse.Options);
    writeByte(NetworkResponseOptions.setTimeVisible);
    writeBool(value);
  }

  void writeOptionsSetHighlightIconInventory(bool value){
    writeByte(NetworkResponse.Options);
    writeByte(NetworkResponseOptions.setHighlightIconInventory);
    writeBool(value);
  }

  void setGame(AmuletGame game){
    endInteraction();
    clearPath();
    clearTarget();
    clearCache();
    setDestinationToCurrentPosition();
    this.game = game;
    this.amuletGame = game;
  }

  void writeWorldMapBytes(){
    print("amuletPlayer.writeWorldMapBytes()");
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.World_Map_Bytes);
    writeByte(amulet.worldRows);
    writeByte(amulet.worldColumns);
    writeUInt16(amulet.worldMapBytes.length);
    writeBytes(amulet.worldMapBytes);
  }

  void writeWorldMapLocations(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.World_Map_Locations);
    writeUInt16(amulet.worldMapLocations.length);
    writeBytes(amulet.worldMapLocations);
  }

  void writeWorldIndex(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_World_Index);
    writeByte(amuletGame.worldRow);
    writeByte(amuletGame.worldColumn);
  }

  void writeQuestMain(QuestMain value){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Quest_Main);
    writeByte(value.index);
  }

  void completeQuestMain(QuestMain quest) {
    if (questMain.index > quest.index){
      return;
    }
    if (quest == QuestMain.values.last){
      return;
    }
    setQuestMain(QuestMain.values[quest.index + 1]);
  }

  @override
  void onChangedAimTarget() {
    super.onChangedAimTarget();
    writeAimTargetFiendType();
    writeAimTargetItemType();
  }

  void writeAimTargetFiendType() {
    final aimTarget = this.aimTarget;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Aim_Target_Fiend_Type);

    if (aimTarget is! AmuletFiend) {
      writeBool(false);
      return;
    }

    writeBool(true);
    writeByte(aimTarget.fiendType.index);
  }

  void writeFalse() => writeBool(false);

  void writeTrue() => writeBool(true);

  void writeAimTargetItemType() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Aim_Target_Item_Type);

     if (aimTarget is! AmuletGameObject){
       writeFalse();
       return;
     }

    writeTrue();
    final gameObject = aimTarget as AmuletGameObject;
    writeAmuletItem(gameObject.amuletItem);
  }

  void writePlayerMagic() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Magic);
    writeUInt16(maxMagic);
    writeUInt16(magic);
  }

  void regenHealthAndMagic() {
     if (dead) return;
     health += regenHealth;
     magic += regenMagic;
  }

  @override
  set skillTypeLeft(SkillType value) {
    if (!skillTypeUnlocked(value)){
      return;
    }
    super.skillTypeLeft = value;
    writeSkillsLeftRight();
  }

  @override
  set skillTypeRight(SkillType value) {
    if (!skillTypeUnlocked(value)){
      return;
    }
    super.skillTypeRight = value;
    writeSkillsLeftRight();
  }

  void writeSkillsLeftRight(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skills_Left_Right);
    writeByte(skillTypeLeft.index);
    writeByte(skillTypeRight.index);
  }

  void performSkillLeft(){
    activeSkillActiveLeft();
    performForceAttack();
  }

  void performSkillRight(){
    activeSkillActiveRight();
    performForceAttack();
  }

  @override
  void setSkillActiveLeft(bool value) {
    if (deadOrBusy && !value){
      return;
    }
    super.setSkillActiveLeft(value);
  }

  bool get equippedWeaponMelee {
    final subType = equippedWeapon?.subType;
    return subType != null && WeaponType.valuesMelee.contains(subType);
  }

  bool get equippedWeaponBow => equippedWeapon?.isWeaponBow ?? false;

  bool get equippedWeaponStaff => equippedWeapon?.isWeaponStaff ?? false;

  bool get equippedWeaponSword => equippedWeapon?.isWeaponSword ?? false;

  void selectSkillTypeLeft(SkillType value) {
    skillTypeLeft = value;
  }

  void selectSkillTypeRight(SkillType value) {
    skillTypeRight = value;
  }

  void writeAmuletEvent({
    required Position position,
    required int amuletEvent,
  }){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Amulet_Event);
    writePosition(position);
    writeByte(amuletEvent);
  }

  int getSkillTypeDamageMin(SkillType skillType) =>
      getSkillTypeDamageDivider(skillType, 4);

  int getSkillTypeDamageMax(SkillType skillType) =>
      getSkillTypeDamageDivider(skillType, 3);

  int get equippedWeaponDamage {
    final damage = equippedWeapon?.damage;
    if (damage == null){
      throw Exception('equippedWeapon is null');
    }
    return damage;
  }

  int getSkillTypeDamageDivider(SkillType skillType, int divider){

    if (const [
      SkillType.Heal,
      SkillType.Teleport,
      SkillType.Warlock,
      SkillType.Vampire,
      SkillType.None,
    ].contains(skillType)){
      return 0;
    }

    if (skillType == SkillType.Strike) {
      return equippedWeaponDamage + proficiencySword ~/ divider;
    }

    if (const [
      SkillType.Shoot_Arrow,
      SkillType.Split_Shot,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
    ].contains(skillType)) {
      return equippedWeaponDamage + proficiencyBow ~/ divider;
    }

    switch (skillType) {
      case SkillType.Mighty_Strike:
        return (equippedWeaponDamage + proficiencySword ~/ divider) * 2;
      case SkillType.Frostball:
        return 5 + proficiencyStaff ~/ divider;
      case SkillType.Fireball:
        return 5 + proficiencyStaff ~/ divider;
      case SkillType.Explode:
        return 10 + proficiencyStaff ~/ divider;
      default:
        throw Exception('$skillType.damage unknown');
    }
  }

  int getSkillTypeDamage(SkillType skillType) {
    final minDamage = getSkillTypeDamageMin(skillType);
    final maxDamage = getSkillTypeDamageMax(skillType);

    if (minDamage == maxDamage) {
      return minDamage;
    }

    if (minDamage > maxDamage) {
      throw Exception('min damage > max damage');
    }

    return randomInt(
      minDamage,
      maxDamage,
    );
  }

  double getSkillTypeRange(SkillType skillType) =>
    skillType.range ??
        equippedWeapon?.range ??
          (throw Exception('amuletPlayer.getSkillTypeRange($skillType)'));


  double getSkillTypeRadius(SkillType skillType) {
     switch (skillType){
       case SkillType.Explode:
         return 50;
       default:
         return 0;
     }
  }

  int getSkillTypeMagicCost(SkillType skillType) => skillType.magicCost;

  WeaponClass? get equippedWeaponClass {
      final weaponType = equippedWeapon?.subType;
      if (weaponType == null){
        return null;
      }
      return WeaponClass.fromWeaponType(weaponType);
  }

  void writeSkillTypes() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Types);
    for (final skillType in SkillType.values){
      if (!skillTypeUnlocked(skillType)){
        writeFalse();
        continue;
      }
      writeTrue();
      writeByte(getSkillTypeMagicCost(skillType));
      writeUInt16(getSkillTypeDamageMin(skillType));
      writeUInt16(getSkillTypeDamageMax(skillType));
      writeUInt16(getSkillTypeRange(skillType).toInt());
      writeUInt16(getSkillTypePerformDuration(skillType).toInt());
      writeUInt16(getSkillTypeAmount(skillType).toInt());
    }
  }

  bool skillTypeUnlocked(SkillType skillType) {
    if (skillType == SkillType.None){
      return true;
    }
    if (skillType == SkillType.Strike){
      return equippedWeaponMelee;
    }
    if (skillType == SkillType.Shoot_Arrow){
      return equippedWeaponBow;
    }
    return equippedWeapon?.skillType == skillType ||
      equippedHelm?.skillType == skillType ||
      equippedArmor?.skillType == skillType ||
      equippedShoes?.skillType == skillType;
  }

  @override
  void setCharacterStateHurt({int duration = 10}) {
    super.setCharacterStateHurt(duration: duration);
    activeSkillActiveLeft();
  }

  void writeCharacteristics() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Characteristics);
    writeUInt16(proficiencySword);
    writeUInt16(proficiencyStaff);
    writeUInt16(proficiencyBow);
  }

  void writeActiveSlotType() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Active_Slot_Type);
    writeInt8(activeSlotType?.index ?? -1);
  }

  AmuletItem? getEquippedSlotType(SlotType? slotType) =>
    switch (slotType){
       SlotType.Weapon => equippedWeapon,
       SlotType.Helm => equippedHelm,
       SlotType.Armor => equippedArmor,
       SlotType.Shoes => equippedShoes,
       null => null
    };

  void checkActiveSlotType() {
     final value = activeSlotType;
     if (value == null) return;
     final amuletItem = getEquippedSlotType(activeSlotType);
     if (amuletItem == null){
       clearActiveSlotType();
     }
  }

  void clearActiveSlotType() {
    selectSlotType(null);
  }

  void selectSlotType(SlotType? slotType) {
    if (slotType == null) {
      return;
    }
    final equipped = getEquippedSlotType(slotType);
    if (equipped == null){
      return;
    }
    final equippedSkillType = equipped.skillType;
    if (equippedSkillType == null){
      return;
    }
    skillTypeRight = equippedSkillType;
  }

  int getSkillTypePerformDuration(SkillType skillType) =>
    skillType.casteDuration ??
      equippedWeapon?.performDuration ??
        (throw Exception('skillType.casteDuration and equippedWeapon is null'));

  int getSkillTypeAmount(SkillType skillType) {
    switch (skillType){
      case SkillType.Heal:
        return 10;
      default:
        return 0;
    }
  }

  bool skillTypeEquipped(SkillType skillType) =>
      equippedWeapon?.skillType == skillType ||
      equippedHelm?.skillType == skillType ||
      equippedArmor?.skillType == skillType ||
      equippedShoes?.skillType == skillType ;

  int get healthSteal {
    var total = 0;
    if (skillTypeEquipped(SkillType.Vampire)) {
      total++;
    }
    return total;
  }

  int get magicSteal {
    var total = 0;
    if (skillTypeEquipped(SkillType.Warlock)) {
      total++;
    }
    return total;
  }

  void writeFiendCount() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Fiend_Count);

    var totalAlive = 0;
    var totalDead = 0;

    final characters = game.characters;
    for (final character in characters){
      if (character is! AmuletFiend) continue;
      if (character.alive) {
        totalAlive++;
      } else {
        totalDead++;
      }
    }

    writeUInt16(totalAlive);
    writeUInt16(totalDead);
  }

  void leaveCurrentGame() => game.removePlayer(this);

  void joinGame(AmuletGame game){
    leaveCurrentGame();
    game.add(this);
  }

  void setFlaskAmount(int value){
    flaskAmount = clamp(value, 0, flaskCapacity);
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Flask_Percentage);
    writePercentage(flaskAmount / flaskCapacity);
  }

  void incrementFlask() {
    if (flaskAmount >= flaskCapacity) return;
    setFlaskAmount(flaskAmount + 1);
  }

  void useFlask() {
    if (flaskAmount < flaskCapacity) {
      writeGameError(GameError.Flask_Not_Ready);
      return;
    }
    setFlaskAmount(0);
    regainFullHealth();
    regainFullMagic();
    writePlayerEvent(PlayerEvent.Drink);
  }
}
