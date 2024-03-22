
import 'dart:math';

import 'package:amulet_common/src.dart';
import 'package:amulet_server/classes/mixins/aim_target_text.dart';
import 'package:amulet_server/classes/mixins/mixin_can_upgrade.dart';
import 'package:amulet_server/classes/mixins/mixin_potions.dart';
import 'package:amulet_server/src.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_math/src.dart';

import 'amulet.dart';
import 'amulet_fiend.dart';
import '../isometric/src.dart';

class AmuletPlayer extends IsometricPlayer with
    Equipped,
    Skilled,
    Gold,
    MixinCanUpgrade,
    MixinPotions,
    AimTargetText
{
  static const Data_Key_Dead_Count = 'dead';

  var questTutorial = QuestTutorial.values.first;
  var questMain = QuestMain.values.first;
  var baseHealth = 10.0;
  var baseMagic = 10.0;
  var baseRegenMagic = 1;
  var baseRegenHealth = 1;
  var baseRunSpeed = 1.0;

  var castePositionX = 0.0;
  var castePositionY = 0.0;
  var castePositionZ = 0.0;

  var admin = false;
  var previousCameraTarget = false;
  var equipmentDirty = true;
  var skillsLeftRightDirty = true;

  var cacheRegenMagic = 0;
  var cacheRegenHealth = 0;
  var cacheRunSpeed = 0.0;
  var cacheAgility = 0;
  var cacheWeaponDamageMin = 0;
  var cacheWeaponDamageMax = 0;
  var cacheWeaponRange = 0;
  var cachePerformFrameVelocity = -1.0;
  var cacheHealthSteal = -1;
  var cacheMagicSteal = -1;
  var debugEnabled = false;
  var maxPotions = 4;

  var npcText = '';
  var npcName = '';
  var npcOptions = <TalkOption>[];
  var flags = <dynamic>[];
  var skillSlotIndex = 0;
  var active = false;
  var difficulty = Difficulty.Normal;

  bool get canCheat => amulet.cheatsEnabled;

  GameObject? collectableGameObject;
  AmuletItemObject? collectableAmuletItemObject;

  void setCollectableGameObject(GameObject? gameObject){

    if (collectableGameObject == gameObject) {
       return;
     }

     if (gameObject != null) {
       interacting = true;
       collectableGameObject = gameObject;
       collectableAmuletItemObject = mapGameObjectToAmuletItemObject(gameObject);
     } else {
       clearCollectableGameObject();
     }

     writeCollectableAmuletItemObject();
  }

  void clearCollectableGameObject(){
    collectableGameObject = null;
    collectableAmuletItemObject = null;
  }

  final sceneShrinesUsed = <AmuletScene, List<int>> {};

  Function? onInteractionOver;
  Position? cameraTarget;
  AmuletGame amuletGame;

  AmuletPlayer({
    required this.amuletGame,
    required int itemLength,
    required super.x,
    required super.y,
    required super.z,
  }) : super(game: amuletGame, health: 10, team: TeamType.Good) {
    respawnDurationTotal = -1;
    characterType = CharacterType.Human;
    hurtable = false;
    hurtStateBusy = false;
    runToDestinationEnabled = true;
    pathFindingEnabled = false;
    equipmentDirty = true;

    regainFullHealth();
    regainFullMagic();
    setControlsEnabled(true);
    writeWorldMapBytes();
    writeWorldMapLocations();
    writeInteracting();
    writeGender();
    writePlayerComplexion();
  }

  /// in frames
  int? get equippedWeaponPerformDuration {
    return AmuletSettings.interpolateAttackSpeed(attackSpeedI).toInt();
  }

  @override
  set magic(double value) {
    value = value.clamp(0, maxMagic);
    super.magic = value;
    writePlayerMagic();
  }

  void setQuestMain (QuestMain value){
    this.questMain = value;
    writeQuestMain(value);
  }

  bool get noWeaponEquipped => equippedWeapon == null;

  Amulet get amulet => amuletGame.amulet;

  @override
  int get weaponType => equippedWeapon?.amuletItem.subType ?? WeaponType.Unarmed;

  @override
  double get attackRange {
    return equippedWeaponRange ?? 0;
  }

  @override
  int get helmType => equippedHelm?.amuletItem.subType ?? HelmType.None;

  @override
  double get maxHealth {
    var total = baseHealth;
    total += equippedWeapon?.maxHealth ?? 0;
    total += equippedHelm?.maxHealth ?? 0;
    total += equippedArmor?.maxHealth ?? 0;
    total += equippedShoes?.maxHealth ?? 0;
    return total;
  }

  @override
  double get maxMagic {
    var total = baseMagic;
    total += equippedWeapon?.maxMagic ?? 0;
    total += equippedHelm?.maxMagic ?? 0;
    total += equippedArmor?.maxMagic ?? 0;
    total += equippedShoes?.maxMagic ?? 0;
    return total;  }

  @override
  set target(Position? value){
    if (super.target == value) {
      return;
    }

    if (value != null){

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
      setCollectableGameObject(null);
      onInteractionOver?.call();
      onInteractionOver = null;
      cameraTarget = null;
    }

    writeInteracting();
  }

  int get regenMagic =>
      AmuletSettings.Base_Magic_Regen +
        getSkillTypeLevel(SkillType.Magic_Regen);

  int get regenHealth =>
      AmuletSettings.Base_Magic_Regen +
          getSkillTypeLevel(SkillType.Health_Regen);

  @override
  double get runSpeed {
    final level = getSkillTypeLevel(SkillType.Run_Speed);
    final bonus = baseRunSpeed * SkillType.getRunSpeed(level);
    return baseRunSpeed + bonus;
  }

  int get attackSpeed => getSkillTypeLevel(SkillType.Attack_Speed);
  
  double get attackSpeedI => attackSpeed / SkillType.Attack_Speed.maxLevel;

  @override
  void writePlayerGame() {

    cleanEquipment();
    cleanSkillsLeftRight();
    writeCameraTarget();
    writePerformFrameVelocity();
    writeSufficientMagicForSkillRight();

    if (debugEnabled){
      writeDebug();
    }

    writeAmuletPlayerAimTarget();
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

  void writeAgility() {
    if (cacheAgility == attackSpeed) return;
    cacheAgility = attackSpeed;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Agility);
    writeUInt16(attackSpeed);
  }

  void writeDebug() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Debug);
    final characters = game.characters;
    for (final character in characters) {
        final target = character.target;
        if (target == null) continue;
        writeTrue();
        writePosition(character);
        writePosition(target);
    }
    writeFalse();
  }

  void acquireGameObject(GameObject gameObject){

    clearTarget();
    final amuletItem = gameObject.amuletItem;

    if (amuletItem == null){
      writeGameError(GameError.GameObject_Cannot_Be_Acquired);
      return;
    }

    final amuletItemObject = mapGameObjectToAmuletItemObject(gameObject);

    if (amuletItemObject == null) {
      writeGameError(GameError.Invalid_GameObject_State);
      return;
    }

    if (amuletItem == AmuletItem.Consumable_Potion_Magic){
       if (potionsMagic >= maxPotions) {
         writeGameError(GameError.Potions_Magic_Full);
         return;
       }
       setCharacterStateChanging();
       amuletGame.remove(gameObject);
       potionsMagic++;
       return;
    }

    if (amuletItem == AmuletItem.Consumable_Potion_Health){
       if (potionsHealth >= maxPotions) {
         writeGameError(GameError.Potions_Health_Full);
         return;
       }
       setCharacterStateChanging();
       amuletGame.remove(gameObject);
       potionsHealth++;
       return;
    }
  }


  bool acquireAmuletItemObject(AmuletItemObject amuletItemObject){
    if (deadOrBusy) {
      return false;
    }
    setDestinationToCurrentPosition();
    clearPath();
    equipAmuletItemObject(value: amuletItemObject);
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
      // if (value.collectable) {
      //   return TargetAction.Collect;
      // }
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
        TalkOptions? options,
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
       npcOptions = options.entries.toList(growable: false);
     } else {
       npcOptions = [];
     }
     writeNpcTalk();
  }

  @override
  int get aimTargetAction {
    final aimTarget = this.aimTarget;

    if (aimTarget == null){
      return TargetAction.Run;
    }

    if (aimTarget is GameObject){
       if (aimTarget.isAmuletItem){
         return TargetAction.Collect;
       }
    }

    if (aimTarget is AmuletNpc){
      return TargetAction.Talk;
    }

    return TargetAction.Attack;
  }

  void endInteraction() {
    if (!interacting) return;
    interacting = false;
    npcName = '';
    npcText = '';
    npcOptions = [];
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.End_Interaction);
    clearTarget();
  }

  void spawnAmuletItem({
    required AmuletItem amuletItem,
    required int level,
  }) {
    if (level <= 0) {
      writeGameError(GameError.Invalid_Amulet_Item_Level);
      return;
    }

    spawnAmuletItemObject(
        AmuletItemObject(
          amuletItem: amuletItem,
          level: level,
        ));
  }

  void spawnAmuletItemObject(AmuletItemObject amuletItemObject){
    const spawnDistance = 20.0;
    final spawnAngle = randomAngle();
    amuletGame.spawnAmuletItemObject(
      x: x + adj(spawnAngle, spawnDistance),
      y: y + opp(spawnAngle, spawnDistance),
      z: z,
      amuletItemObject: amuletItemObject,
    );
  }

  void selectNpcTalkOption(int index) {
    final talkOption = npcOptions.tryGet(index);
     if (talkOption == null){
       writeAmuletError('Invalid talk option index $index');
       return;
     }
     talkOption.value.call(this);
  }

  void cleanEquipment(){
    if (!equipmentDirty) {
      return;
    }


    checkAssignedSkills();

    health = clamp(health, 0, maxHealth);
    weaponType = equippedWeapon?.amuletItem.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;
    helmType = equippedHelm?.amuletItem.subType ?? HelmType.None;
    armorType = equippedArmor?.amuletItem.subType ?? 0;
    shoeType = equippedShoes?.amuletItem.subType ?? ShoeType.None;
    writeEquipped();
    writePlayerHealth();
    writePlayerMagic();
    writeSkillTypes();
    writePlayerCriticalHitPoints();
    writeSkillActiveLeft();
  }

  SkillType get equippedWeaponDefaultSkillType {
    if (equippedWeaponBow) {
      return SkillType.Shoot_Arrow;
    }
    if (equippedWeaponStaff) {
      return SkillType.Bludgeon;
    }
    if (equippedWeaponSword) {
      return SkillType.Slash;
    }
    return SkillType.None;
  }

  void writeEquipped(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Equipped);
    writeAmuletItemObject(equippedWeapon);
    writeAmuletItemObject(equippedHelm);
    writeAmuletItemObject(equippedArmor);
    writeAmuletItemObject(equippedShoes);
  }

  void writeAmuletItem(AmuletItem? value){
    if (value == null){
      writeInt16(-1);
    } else{
      writeInt16(value.index);
    }
  }

  void writeAmuletItemObject(AmuletItemObject? value) =>
      tryWrite(tryWriteAmuletItemObject, value);

  void tryWriteAmuletItemObject(AmuletItemObject value){
    writeUInt16(value.amuletItem.index);
    writeUInt16(value.level);
  }

  void writeDecimal(double value) => writeUInt16((value * 10).toInt());

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
      writeString(option.key);
    }
  }

  @override
  void setCharacterStateChanging({int duration = 15}) {
    super.setCharacterStateChanging(duration: duration);
    writePlayerEvent(PlayerEvent.Character_State_Changing);
  }

  void updateCastePosition() {
    final skillType = activeSkillType;
    final mouseDistance = getMouseDistance();
    final weaponRange = equippedWeaponRange;

    if (weaponRange == null){
      return;
    }


    if (mouseDistance <= weaponRange){
      castePositionX = mouseSceneX;
      castePositionY = mouseSceneY;
      castePositionZ = mouseSceneZ;
    } else {
      final mouseAngle = getMouseAngle() + pi;
      castePositionX = x + adj(mouseAngle, weaponRange);
      castePositionY = y + opp(mouseAngle, weaponRange);
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

  void equipAmuletItemObject({
    required AmuletItemObject value,
    bool force = false,
  }) {
    final amuletItem = value.amuletItem;

    if (amuletItem.isConsumable) {
      writeGameError(GameError.Cannot_Be_Equipped);
      return;
    }

    final currentlyEquipped = getEquippedAmuletItem(slotType: amuletItem.slotType);
    if (currentlyEquipped != null) {
      dropSlotType(currentlyEquipped.amuletItem.slotType);
    }

    switch (amuletItem.slotType) {
      case SlotType.Weapon:
        equippedWeapon = value;
        break;
      case SlotType.Helm:
        equippedHelm = value;
        break;
      case SlotType.Armor:
        equippedArmor = value;
        break;
      case SlotType.Shoes:
        equippedShoes = value;
        break;
      case SlotType.Consumable:
        break;
    }

    final skillPoints = value.amuletItem.skillSet.entries;

    for (final skillPoint in skillPoints){
      final skillType = skillPoint.key;
      final level = getSkillTypeLevel(skillType);
      if (level <= 0) continue;
    }

    notifyEquipmentDirty();
  }

  @override
  set equippedWeapon(AmuletItemObject? value) {

    if (value == null){
      super.equippedWeapon = null;
      notifyEquipmentDirty();
      return;
    }

    final amuletItem = value.amuletItem;

    if (amuletItem.slotType != SlotType.Weapon) {
      writeGameError(GameError.Invalid_Weapon_Type);
      return;
    }

    final attackSkill = amuletItem.attackSkill;
    if (attackSkill == null){
      writeGameError(GameError.Invalid_Weapon_Type);
      return;
    }
    super.equippedWeapon = value;
    skillTypeLeft = attackSkill;
    if (skillTypeRight == SkillType.None){
      skillTypeRight = equippedWeaponDefaultSkillType;
    }
    notifyEquipmentDirty();
  }

  void notifyEquipmentDirty() {
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

  void dropSlotType(SlotType slotType){
      final equippedAmuletItem = getEquippedAmuletItem(slotType: slotType);
      if (equippedAmuletItem == null){
        return;
      }

      spawnAmuletItemObject(equippedAmuletItem);
      switch (equippedAmuletItem.amuletItem.slotType) {
        case SlotType.Weapon:
          equippedWeapon = null;
          break;
        case SlotType.Helm:
          equippedHelm = null;
          break;
        case SlotType.Armor:
          equippedArmor = null;
          break;
        case SlotType.Shoes:
          equippedShoes = null;
          break;
        case SlotType.Consumable:
          break;
      }

      writePlayerEvent(PlayerEvent.Item_Dropped);
      notifyEquipmentDirty();
  }

  AmuletItemObject? getEquippedAmuletItem({required SlotType slotType}) =>
      switch (slotType) {
        SlotType.Weapon => equippedWeapon,
        SlotType.Helm => equippedHelm,
        SlotType.Armor => equippedArmor,
        SlotType.Shoes => equippedShoes,
        SlotType.Consumable => null,
      };

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

    if (deadOrBusy || activeSkillType == SkillType.None) {
      return;
    }

    if (activeSkillType.casteType == CasteType.Passive){
      writeGameError(GameError.Cannot_Perform_Passive_Ability);
      return;
    }

    if (!activeSkillType.isCaste){
      if (equippedWeaponSword && !activeSkillType.enabledSword){
        writeGameError(GameError.Invalid_Weapon_Type);
        return;
      }

      if (equippedWeaponStaff && !activeSkillType.enabledStaff){
        writeGameError(GameError.Invalid_Weapon_Type);
        return;
      }

      if (equippedWeaponBow && !activeSkillType.enabledBow){
        writeGameError(GameError.Invalid_Weapon_Type);
        return;
      }
    }


    final magicCost = getSkillTypeMagicCost(activeSkillType);
    if (magicCost > magic) {
      writeGameError(GameError.Insufficient_Magic);
      clearTarget();
      return;
    }

    final performDuration = equippedWeaponPerformDuration;
    if (performDuration == null){
      writeGameError(GameError.Perform_Duration_Null);
      clearTarget();
      return;
    }

    magic -= magicCost;

    if (activeSkillType.isCaste){
      setCharacterStateCasting(duration: performDuration);
      return;
    }

    if (equippedWeaponBow){
      setCharacterStateFire(duration: performDuration);
    } else {
      setCharacterStateStriking(duration: performDuration);
    }
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
    writeOptionsSetTimeVisible(false);
    writeOptionsSetHighlightIconInventory(false);
    writeSkillTypes();
    // writeSkillsLeftRight();
    writeFiendCount();
    writeDebugEnabled();
    writeSkillSlotIndex();
    writePlayerCanUpgrade();
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

  void writeFalse() => writeBool(false);

  void writeTrue() => writeBool(true);

  void writeCollectableAmuletItemObject() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Collectable_Amulet_Item_Object);
    writeAmuletItemObject(collectableAmuletItemObject);
  }

  AmuletItem? getGameObjectAmuletItem(GameObject gameObject){
     if (gameObject.itemType != ItemType.Amulet_Item) {
       return null;
     }
     return AmuletItem.values[gameObject.subType];
  }

  void writePlayerMagic() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Magic);
    writeUInt16(maxMagic.toInt());
    writeUInt16(magic.toInt());
  }

  void regenHealthAndMagic() {
     if (dead) return;
     health += regenHealth;
     magic += regenMagic;
  }

  @override
  set skillTypeLeft(SkillType value) {
    if (!skillTypeUnlocked(value)){
      writeGameError(GameError.Skill_Type_Locked);
      return;
    }
    super.skillTypeLeft = value;
    markSkillsLeftRightDirty();
  }

  void cleanSkillsLeftRight(){
     if (!skillsLeftRightDirty) return;
     writeSkillsLeftRight();
     skillsLeftRightDirty = false;
  }

  void markSkillsLeftRightDirty(){
    skillsLeftRightDirty = true;
  }

  // @override
  // SkillType get skillTypeRight => skillSlots[skillSlotIndex];

  @override
  set skillTypeRight(SkillType value) {
    if (!skillTypeUnlocked(value)){
      writeGameError(GameError.Skill_Type_Locked);
      return;
    }

    super.skillTypeRight = value;
    markSkillsLeftRightDirty();
  }

  void writeSkillsLeftRight(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skills_Left_Right);
    writeByte(skillTypeLeft.index);
    writeByte(skillTypeRight.index);
  }

  void performSkillLeft(){
    activeSkillActiveLeft();
    if (skillActiveLeft) {
      performForceAttack();
    }
  }

  void performSkillRight(){
    activeSkillActiveRight();
    if (!skillActiveLeft){
      performForceAttack();
    }

  }

  bool get equippedWeaponBow => equippedWeapon?.amuletItem.isWeaponBow ?? false;

  bool get equippedWeaponStaff => equippedWeapon?.amuletItem.isWeaponStaff ?? false;

  bool get equippedWeaponSword => equippedWeapon?.amuletItem.isWeaponSword ?? false;

  bool get equippedWeaponMelee => equippedWeaponSword || equippedWeaponStaff;

  bool get equippedWeaponRanged => equippedWeaponBow;

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

  void writeAmuletPlayerAimTarget() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Aim_Target);

    final aimTarget = this.aimTarget;
    final aimNodeIndex = this.aimNodeIndex;

    if (aimNodeIndex == null && aimTarget == null){
      writeFalse();
      return;
    }
    writeTrue();

    var name = '';
    var subtitles = '';
    ItemQuality? itemQuality;
    int? level;
    var healthPercentage = 0.0;


    if (aimNodeIndex != null) {
      final nodeType = scene.nodeTypes[aimNodeIndex];
      if (nodeType == NodeType.Shrine){
        name = 'Shrine';
      }
      if (nodeType == NodeType.Portal){
         final sceneIndex = scene.variations[aimNodeIndex];
         final amuletScene = AmuletScene.values.tryGet(sceneIndex);
         if (amuletScene != null){
           name = amuletScene.name.clean;
         } else {
           name = 'invalid';
         }
      }

      if (nodeType == NodeType.Fireplace) {
        name = 'upgrade';
      }

    } else if (aimTarget != null){
      name = aimTarget.name;
      if (aimTarget is Character) {
        healthPercentage = aimTarget.healthPercentage;
      }
      if (aimTarget is GameObject) {
        level = aimTarget.level;
        final amuletItem = aimTarget.amuletItem;
        if (amuletItem != null) {
          name = amuletItem.label;
          itemQuality = amuletItem.quality;
          healthPercentage = 0;
        } else {
          healthPercentage = aimTarget.healthPercentage;
        }
      }
      if (aimTarget is AmuletFiend){
        level = aimTarget.level;
        final fiendType = aimTarget.fiendType;
        subtitles = buildResistances(subtitles, 'melee', fiendType.meleeResistance);
        subtitles = buildResistances(subtitles, 'pierce', fiendType.pierceResistance);
        subtitles = buildResistances(subtitles, 'fire', fiendType.fireResistance);
        subtitles = buildResistances(subtitles, 'ice', fiendType.iceResistance);
      }
    }

    writeString(name);
    writePercentage(healthPercentage);
    tryWriteUInt16(level);
    tryWriteByte(itemQuality?.index);
    tryWrite(writeString, subtitles);
  }

  double? get randomEquippedWeaponDamage {

    final equippedWeapon = this.equippedWeapon;
    if (equippedWeapon == null) {
      return null;
    }

    final attackSkill = equippedWeapon.amuletItem.attackSkill;
    if (attackSkill == null) {
      assert(false);
      return null;
    }

    final attackSkillLevel = getSkillTypeLevel(attackSkill);

    if (attackSkillLevel <= 0){
      return null;
    }

    final damageMin = attackSkill.getDamageMin(attackSkillLevel);
    final damageMax = attackSkill.getDamageMin(attackSkillLevel);

    if (damageMin == null || damageMax == null){
      assert(false);
      return null;
    }

    return randomBetween(damageMin, damageMax);
  }

  int get equippedWeaponLevel => equippedWeapon?.level ?? 0;

  double getSkillTypeRadius(SkillType skillType) {
     switch (skillType){
       case SkillType.Explode:
         return 50;
       default:
         return 0;
     }
  }

  int getSkillTypeMagicCost(SkillType skillType) => skillType.magicCost;

  double? get equippedWeaponRange {
    return equippedWeapon?.amuletItem.getRange(
        getSkillTypeLevel(SkillType.Attack_Range));
  }

  int getSkillTypeLevel(SkillType skillType){
     var total = 0;
     total += equippedWeapon?.getSkillLevel(skillType) ?? 0;
     total += equippedHelm?.getSkillLevel(skillType) ?? 0;
     total += equippedArmor?.getSkillLevel(skillType) ?? 0;
     total += equippedShoes?.getSkillLevel(skillType) ?? 0;
     return min(total, skillType.maxLevel);
  }

  void writeSkillTypes() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Types);
    for (final skillType in SkillType.values){
      writeByte(skillType.index);
      writeUInt16(getSkillTypeLevel(skillType));
    }
  }

  bool skillTypeLocked(SkillType skillType)=> !skillTypeUnlocked(skillType);

  bool skillTypeUnlocked(SkillType skillType) =>
    skillType == SkillType.None ||
    getSkillTypeLevel(skillType) > 0;

  @override
  void setCharacterStateHurt({int duration = 10}) {
    super.setCharacterStateHurt(duration: duration);
    activeSkillActiveLeft();
  }

  double get healthSteal =>
      SkillType.getHealthSteal(getSkillTypeLevel(SkillType.Health_Steal));

  double get magicSteal =>
      SkillType.getMagicSteal(getSkillTypeLevel(SkillType.Magic_Steal));

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

  @override
  double get frameVelocity {
    if (actionFrame > 0){
      return performFrameVelocity;
    }
    return super.frameVelocity;
  }

  double get performFrameVelocity {
    final attackSpeedLevel = getSkillTypeLevel(SkillType.Attack_Speed);
    final attackSpeedPerc = SkillType.getAttackSpeed(attackSpeedLevel);
    final base = AmuletSettings.Min_Perform_Velocity;
    return base + (base * attackSpeedPerc);
  }

  void writePerformFrameVelocity() {
    final frameVelocity = performFrameVelocity;
    if (cachePerformFrameVelocity == frameVelocity) return;

    cachePerformFrameVelocity = frameVelocity;
     writeByte(NetworkResponse.Amulet);
     writeByte(NetworkResponseAmulet.Perform_Frame_Velocity);
     writeUInt16((frameVelocity * 1000).toInt());
  }

  @override
  void clearCache() {
    super.clearCache();
    cachePerformFrameVelocity = -1;
  }

  double get areaDamage {
    final level = getSkillTypeLevel(SkillType.Area_Damage);
    return SkillType.Area_Damage.getLinear(level);
  }

  double get chanceOfCriticalDamage =>
      SkillType.getPercentageCriticalHit(
          getSkillTypeLevel(SkillType.Critical_Hit)
      );

  int get totalCriticalHitPoints =>
      getSkillTypeLevel(SkillType.Critical_Hit);

  void writePlayerCriticalHitPoints() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Critical_Hit_Points);
    writeByte(totalCriticalHitPoints);
  }

  @override
  set skillActiveLeft(bool value) {
    super.skillActiveLeft = value;
    writeSkillActiveLeft();
  }

  void writeSkillActiveLeft(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Active_Left);
    writeBool(skillActiveLeft);
  }

  void toggleDebugEnabled() {
    debugEnabled = !debugEnabled;
    writeDebugEnabled();
  }

  void writeDebugEnabled(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Debug_Enabled);
    writeBool(debugEnabled);
  }

  @override
  bool canInteractWithNodeAtIndex(int index) {
    final nodeType = scene.nodeTypes[index];

    switch (nodeType){
      case NodeType.Shrine:
        final variation = scene.variations[index];
        return variation == NodeType.Variation_Shrine_Active;
      case NodeType.Portal:
        return true;
      case NodeType.Fireplace:
        return true;
      default:
        return false;
    }
  }

  void writeSkillSlotIndex(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Slot_Index);
    writeByte(skillSlotIndex);
  }

  @override
  double get magicPercentage => (magic.percentageOf(maxMagic)).clamp01();

  void writeAmuletItemConsumed(AmuletItem amuletItem){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Amulet_Item_Consumed);
    writeAmuletItem(amuletItem);
  }

  void writeAmuletItemDropped(AmuletItem amuletItem) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Amulet_Item_Dropped);
    writeAmuletItem(amuletItem);
  }

  void writeAmuletItemEquipped(AmuletItem amuletItem) {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Amulet_Item_Equipped);
    writeAmuletItem(amuletItem);
  }

  void toggleSkillType(SkillType skillType) {

    throw Exception();
  }

  void spawnRandomAmuletItem() =>
      spawnAmuletItemObject(
          amuletGame.generateAmuletItemObject(
             amuletItem: randomItem(AmuletItem.values),
             level: amuletGame.randomLevel,
          )
      );

  void pickupAmuletItem() {
    final item = collectableGameObject;

    if (item == null) {
      writeGameError(GameError.Amulet_Item_Null);
      return;
    }
    amuletGame.onAmuletPlayerPickupGameObject(this, item);
  }

  void sellAmuletItem() {
    final item = collectableGameObject;
    if (item == null) {
      writeGameError(GameError.Amulet_Item_Null);
      return;
    }

    writePlayerEvent(PlayerEvent.Item_Sold);
    amuletGame.remove(item);
  }

  @override
  void clearTarget() {
    super.clearTarget();
    clearCollectableGameObject();
  }

  void onPortalUsed({
    required AmuletScene src,
    required AmuletScene dst,
  }){
      if (
      dst == AmuletScene.Witches_Lair_1 &&
      questMain == QuestMain.Find_Witches_Lair) {
        questMain = QuestMain.values[QuestMain.Find_Witches_Lair.index + 1];
      }
  }

  @override
  set gold(double value) {
    super.gold = value;
    writeGold();
  }

  void tryWritePercentage(double? value) =>
      tryWrite(writePercentage, value);

  void upgradeSlotType(SlotType slotType) {

    final amuletItemObject = getEquippedAmuletItem(slotType: slotType);

    if (amuletItemObject == null){
      writeGameError(GameError.Slot_Type_Empty);
      return;
    }

    final upgradeCost = amuletItemObject.amuletItem.getUpgradeCost(amuletItemObject.level);

    if (upgradeCost > gold){
      writeGameError(GameError.Insufficient_Gold);
      return;
    }

    gold -= upgradeCost;

    final upgradeAmuletItemObject = AmuletItemObject(
        amuletItem: amuletItemObject.amuletItem,
        level: amuletItemObject.level + 1,
    );

    switch (slotType) {
      case SlotType.Weapon:
        equippedWeapon = upgradeAmuletItemObject;
        break;
      case SlotType.Helm:
        equippedHelm = upgradeAmuletItemObject;
        break;
      case SlotType.Armor:
        equippedArmor = upgradeAmuletItemObject;
        break;
      case SlotType.Shoes:
        equippedShoes = upgradeAmuletItemObject;
        break;
      case SlotType.Consumable:
        writeGameError(GameError.Not_Implemented);
        break;
    }

    notifyEquipmentDirty();
  }

  void writeGold() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Gold);
    writeUInt24(gold.toInt());
  }

  @override
  set canUpgrade(bool value) {
    if (value == canUpgrade) return;
    super.canUpgrade = value;
    writePlayerCanUpgrade();
  }

  void writePlayerCanUpgrade() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Can_Upgrade);
    writeBool(canUpgrade);
  }

  void cheatAcquireGold() {
     if (!canCheat) {
       writeGameError(GameError.Cheats_Disabled);
       return;
     }
     gold += 100;
  }

  @override
  set potionsMagic(int value) {
    super.potionsMagic = value.clamp(0, maxPotions);
    writePotions();
  }

  @override
  set potionsHealth(int value) {
    super.potionsHealth = value.clamp(0, maxPotions);
    writePotions();
  }

  void writePotions(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Potions);
    writeByte(potionsHealth);
    writeByte(potionsMagic);
  }

  void usePotionHealth() {
     if (potionsHealth <= 0) {
       writeGameError(GameError.Potions_Health_Empty);
       return;
     }
     writePlayerEvent(PlayerEvent.Potion_Consumed);
     potionsHealth--;
     health = maxHealth;
  }

  void usePotionMagic() {
    if (potionsMagic <= 0) {
      writeGameError(GameError.Potions_Magic_Empty);
      return;
    }
    writePlayerEvent(PlayerEvent.Potion_Consumed);
    potionsMagic--;
    magic = maxMagic;
  }

  double getCharacterDamageTypeResistance(DamageType damageType) {

    switch (damageType){
      case DamageType.Slash:
        final level = getSkillTypeLevel(SkillType.Resist_Slash);
        return SkillType.getResistSlash(level);
      case DamageType.Bludgeon:
        final level = getSkillTypeLevel(SkillType.Resist_Bludgeon);
        return SkillType.getResistBludgeon(level);
      case DamageType.Pierce:
        final level = getSkillTypeLevel(SkillType.Resist_Pierce);
        return SkillType.getResistPierce(level);
      case DamageType.Fire:
        final level = getSkillTypeLevel(SkillType.Resist_Fire);
        return SkillType.getResistFire(level);
      case DamageType.Ice:
        final level = getSkillTypeLevel(SkillType.Resist_Ice);
        return SkillType.getResistIce(level);
    }
  }

  void checkAssignedSkills() {


    final attackSkill = equippedWeapon?.amuletItem.attackSkill;

    if (skillTypeLocked(skillTypeLeft)){
      skillTypeLeft = SkillType.None;
    }

    if (skillTypeLeft == SkillType.None && attackSkill != null) {
      skillTypeLeft = attackSkill;
    }

    if (skillTypeLocked(skillTypeRight)){
      skillTypeRight = SkillType.None;
    }

    if (skillTypeRight == SkillType.None || skillTypeRight == attackSkill) {
      final skillSet = equippedWeapon?.amuletItem.skillSet;
      if (skillSet != null) {
         for (final skillType in SkillType.values){
           if (
            skillType.isPassive ||
            skillTypeLocked(skillType) ||
            skillType == attackSkill ||
            !canAssignSkillType(skillType)
           ) continue;
           skillTypeRight = skillType;
         }
      }
    }
  }

  bool canAssignSkillType(SkillType skillType) {
     if (skillType == SkillType.None) return true;
     if (skillTypeLocked(skillType)) return false;
     if (equippedWeaponBow) {
       return skillType.enabledBow;
     }
     if (equippedWeaponStaff){
       return skillType.enabledStaff;
     }
     if (equippedWeaponSword) {
       return skillType.enabledSword;
     }
     return skillType.enabledUnarmed;
  }

  var cacheSufficientMagic = false;

  @override
  bool canAimAt(GameObject gameObject) {
    final amuletItem = gameObject.amuletItem;

    if (amuletItem == null){
      return super.canAimAt(gameObject);
    }

    if (const[
      AmuletItem.Consumable_Meat,
      AmuletItem.Consumable_Sapphire,
    ].contains(amuletItem)){
      return false;
    }

    return super.canAimAt(gameObject);
  }

  void writeSufficientMagicForSkillRight() {
    final skillRightCost = skillTypeRight.magicCost;
    final sufficientMagic = magic >= skillRightCost;

    if (sufficientMagic == cacheSufficientMagic){
      return;
    }

    cacheSufficientMagic = sufficientMagic;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Sufficient_Magic_For_Skill_Right);
    writeBool(sufficientMagic);
  }



}

String buildResistances(String text, String name, double resistance){
   if (resistance == 0)
     return text;
   if (text.isNotEmpty) {
      return '$text, $name';
   }
   return 'resists $name';
}


typedef TalkOption = MapEntry<String, Function(AmuletPlayer player)>;
typedef TalkOptions = Map<String, Function(AmuletPlayer player)>;