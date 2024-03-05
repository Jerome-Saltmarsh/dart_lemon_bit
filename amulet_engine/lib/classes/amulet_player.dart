
import 'dart:math';

import 'package:amulet_engine/json/amulet_field.dart';
import 'package:amulet_engine/src.dart';
import 'package:lemon_json/src.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_math/src.dart';

import 'amulet.dart';
import 'amulet_fiend.dart';
import '../isometric/src.dart';


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
  var cacheAgility = 0;
  var cacheWeaponDamageMin = 0;
  var cacheWeaponDamageMax = 0;
  var cacheWeaponRange = 0;
  var cachePerformFrameVelocity = -1.0;
  var cacheHealthSteal = -1;
  var cacheMagicSteal = -1;
  var debugEnabled = false;

  var npcText = '';
  var npcName = '';
  var npcOptions = <TalkOption>[];
  var flags = <dynamic>[];
  var skillSlotIndex = 0;
  var skillSlotsDirty = false;
  var consumableSlotsDirty = true;

  GameObject? collectableAmuletItemObject;

  void setCollectableAmuletItemObject(GameObject? gameObject){
     if (collectableAmuletItemObject == gameObject) return;
     if (gameObject != null) {
       interacting = true;
     }
     collectableAmuletItemObject = gameObject;
     writeAimTargetAmuletItem();
  }

  final sceneShrinesUsed = <AmuletScene, List<int>> {};
  final skillSlots = List.generate(4, (index) => SkillType.None);
  final consumableSlots = List<AmuletItem?>.generate(4, (index) => null);



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

  AttackSpeed? get equippedWeaponAttackSpeed =>
      equippedWeapon?.amuletItem.attackSpeed;

  @override
  set magic(int value) {
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
  double get attackRange => getSkillTypeRange(skillActive);

  @override
  int get helmType => equippedHelm?.amuletItem.subType ?? HelmType.None;

  @override
  double get maxHealth {
    var total = baseHealth;
    total += equippedWeapon?.amuletItem.maxHealth ?? 0;
    total += equippedHelm?.amuletItem.maxHealth ?? 0;
    total += equippedArmor?.amuletItem.maxHealth ?? 0;
    total += equippedShoes?.amuletItem.maxHealth ?? 0;
    return total.toDouble();
  }

  @override
  int get maxMagic {
    var total = baseMagic;
    total += equippedWeapon?.amuletItem.maxMagic ?? 0;
    total += equippedHelm?.amuletItem.maxMagic ?? 0;
    total += equippedArmor?.amuletItem.maxMagic ?? 0;
    total += equippedShoes?.amuletItem.maxMagic ?? 0;
    return total;
  }

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
      setCollectableAmuletItemObject(null);
      onInteractionOver?.call();
      onInteractionOver = null;
      cameraTarget = null;
    }

    writeInteracting();
  }

  int get regenMagic =>
      AmuletSettings.Base_Magic_Regen +
        getSkillTypeLevelAssigned(SkillType.Magic_Regen);

  int get regenHealth =>
      AmuletSettings.Base_Magic_Regen +
          getSkillTypeLevelAssigned(SkillType.Health_Regen);

  @override
  double get runSpeed {
    final level = getSkillTypeLevelAssigned(SkillType.Run_Speed);
    final bonus = baseRunSpeed * SkillType.getRunSpeed(level);
    return baseRunSpeed + bonus;
  }

  int get attackSpeed => getSkillTypeLevelAssigned(SkillType.Agility);

  @override
  void writePlayerGame() {

    cleanEquipment();
    writeCameraTarget();
    writePerformFrameVelocity();

    if (debugEnabled){
      writeDebug();
    }

    if (skillSlotsDirty){
      writeSkillSlots();
      skillSlotsDirty = false;
    }

    if (consumableSlotsDirty) {
      writeConsumableSlots();
      consumableSlotsDirty = false;
    }

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
    weaponType = equippedWeapon?.amuletItem.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;
    helmType = equippedHelm?.amuletItem.subType ?? HelmType.None;
    armorType = equippedArmor?.amuletItem.subType ?? 0;
    shoeType = equippedShoes?.amuletItem.subType ?? ShoeType.None;
    removeInvalidSkillSlots();
    checkAssignedSkillTypes();
    writeEquipped();
    writePlayerHealth();
    writePlayerMagic();
    writeSkillTypes();
    writeEquippedWeaponRange();
    writeEquippedWeaponAttackSpeed();
    writePlayerCriticalHitPoints();
    writeSkillActiveLeft();
  }

  void checkAssignedSkillTypes() {

    for (var i = 0; i < skillSlots.length; i++){
      final skillType = skillSlots[i];
      final skillLevel = getSkillTypeLevel(skillType);

      if (skillLevel <= 0) {
        skillSlots[i] = SkillType.None;
        notifySkillSlotsDirty();
      }
    }

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

  void writeAmuletItemObject(AmuletItemObject? value){

    if (value == null){
      writeFalse();
      return;
    }

    writeTrue();
    writeUInt16(value.amuletItem.index);
    writeByte(value.skillPoints.length);
    for (final entry in value.skillPoints.entries) {
      writeByte(entry.key.index); // skill type index
      writeUInt16(entry.value); // skill type points
    }

    final damage = value.damage;
    final level = value.level;
    final itemQuality = value.itemQuality;

    if (damage != null) {
      writeTrue();
      writeDecimal(damage);
    } else {
      writeFalse();
    }

    tryWriteUInt16(level);
    tryWriteByte(itemQuality?.index);
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
      writeString(option.text);
    }
  }

  @override
  void setCharacterStateChanging({int duration = 15}) {
    super.setCharacterStateChanging(duration: duration);
    writePlayerEvent(PlayerEvent.Character_State_Changing);
  }

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


  void equipAmuletItemObject({
    required AmuletItemObject value,
    bool force = false,
  }) {
    final amuletItem = value.amuletItem;

    if (amuletItem.isConsumable) {
      final availableIndex = getEmptyConsumableSlotIndex();
      if (availableIndex == null){
        writeGameError(GameError.Potion_Slots_Full);
        return;
      }
      setCharacterStateChanging();
      setConsumableSlot(index: availableIndex, amuletItem: amuletItem);
      writeAmuletItemEquipped(amuletItem);
      return;
    }


    final currentlyEquipped = getEquippedAmuletItem(slotType: amuletItem.slotType);
    if (currentlyEquipped != null) {
      dropSlotType(currentlyEquipped.amuletItem.slotType);
    }

    switch (amuletItem.slotType){
      case SlotType.Weapon:
        equippedWeapon = value;
        if (skillTypeLeft == SkillType.None){
          skillTypeLeft = equippedWeaponDefaultSkillType;
        }
        if (skillTypeRight == SkillType.None){
          skillTypeRight = equippedWeaponDefaultSkillType;
        }
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

    final skillPoints = value.skillPoints.entries;

    for (final skillPoint in skillPoints){
      final skillType = skillPoint.key;
      if (!skillTypeAssignedToSkillSlot(skillType)) {
        tryToAssignSkillTypeToEmptySlot(skillType);
      }
    }

    notifyEquipmentDirty();
  }

  void setConsumableSlot({required int index, AmuletItem? amuletItem}) {
    if (!consumableSlots.isValidIndex(index)) {
      writeGameError(GameError.Invalid_Consumable_Index);
      return;
    }
    consumableSlots[index] = amuletItem;
    consumableSlotsDirty = true;
  }

  int? getEmptyConsumableSlotIndex(){
    for (var i = 0; i < consumableSlots.length; i++){
       if (consumableSlots[i] == null) {
         return i;
       }
    }
    return null;
  }

  void tryToAssignSkillTypeToEmptySlot(SkillType skillType) {
    final availableIndex = getEmptySkillSlotIndex();
    if (availableIndex != null) {
      setSkillSlotValue(
        skillType: skillType,
        index: availableIndex,
      );
    }
  }

  void removeInvalidSkillSlots() {
    for (var i = 0; i < skillSlots.length; i++) {
      final skillSlot = skillSlots[i];
      if (skillTypeUnlocked(skillSlot)) continue;
      setSkillSlotValue(
          index: i,
          skillType: SkillType.None,
      );
    }
  }

  void notifySkillSlotsDirty() => skillSlotsDirty = true;

  bool skillTypeAssignedToSkillSlot(SkillType skillType) {
     return getSkillTypeSlotIndex(skillType) != null;
  }

  int? getEmptySkillSlotIndex() => getSkillTypeSlotIndex(SkillType.None);

  int? getSkillTypeSlotIndex(SkillType skillType) {
    for (var i = 0; i < skillSlots.length; i++) {
      if (skillType != skillSlots[i]) continue;
      return i;
    }
    return null;
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

  bool validateSkillType(SkillType skillType){
    switch (skillType.casteType) {
      case CasteType.Bow:
        if (!equippedWeaponBow) {
          writeGameError(GameError.Bow_Required);
          return false;
        }
        break;
      case CasteType.Staff:
        if (!equippedWeaponStaff) {
          writeGameError(GameError.Staff_Required);
          return false;
        }
        break;
      case CasteType.Sword:
        if (!equippedWeaponSword) {
          writeGameError(GameError.Sword_Required);
          return false;
        }
        break;
      case CasteType.Melee:
        if (!equippedWeaponMelee) {
          writeGameError(GameError.Melee_Weapon_Required);
          return false;
        }
        break;
      default:
        break;
    }

    final magicCost = getSkillTypeMagicCost(skillType);
    if (magicCost > magic) {
      writeGameError(GameError.Insufficient_Magic);
      clearTarget();
      return false;
    }

    return true;

  }

  @override
  void attack() {
    if (deadOrBusy || skillActive == SkillType.None) {
      return;
    }

    switch (skillActive.casteType) {
      case CasteType.Bow:
        if (!equippedWeaponBow) {
          writeGameError(GameError.Bow_Required);
          return;
        }
        break;
      case CasteType.Staff:
        if (!equippedWeaponStaff) {
          writeGameError(GameError.Staff_Required);
          return;
        }
        break;
      case CasteType.Sword:
        if (!equippedWeaponSword) {
          writeGameError(GameError.Sword_Required);
          return;
        }
        break;
      case CasteType.Melee:
        if (!equippedWeaponMelee) {
          writeGameError(GameError.Melee_Weapon_Required);
          return;
        }
        break;
      default:
        break;
    }

    final magicCost = getSkillTypeMagicCost(skillActive);
    if (magicCost > magic) {
      writeGameError(GameError.Insufficient_Magic);
      clearTarget();
      return;
    }

    magic -= magicCost;
    final performDuration = getSkillTypePerformDuration(skillActive);

    switch (skillActive.casteType) {
      case CasteType.Passive:
        return;
      case CasteType.Caste:
        setCharacterStateCasting(duration: performDuration);
        break;
      case CasteType.Bow:
        setCharacterStateFire(duration: performDuration);
        break;
      case CasteType.Staff:
        setCharacterStateStriking(duration: performDuration);
        break;
      case CasteType.Sword:
        setCharacterStateStriking(duration: performDuration);
        break;
      case CasteType.Melee:
        setCharacterStateStriking(duration: performDuration);
        break;
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
    writeSkillsLeftRight();
    writeSkillTypes();
    writeFiendCount();
    writeDebugEnabled();
    writeSkillSlots();
    writeSkillSlotIndex();
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
    // writeAimTargetAmuletItem();
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

  void writeAimTargetAmuletItem() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Aim_Target_Amulet_Item);

     final gameObject = collectableAmuletItemObject;

    if (gameObject == null){
      writeFalse();
      return;
    }

     final amuletItem = getGameObjectAmuletItem(gameObject);

     if (amuletItem == null){
       writeFalse();
       return;
     }

     final data = gameObject.data;
     final indexedSkillPoints = data?[AmuletField.Skill_Points];

     if (indexedSkillPoints == null){
       writeFalse();
       return;
     }

    writeTrue();

    writeUInt16(amuletItem.index);
    writeByte(indexedSkillPoints.length);
    for (final entry in indexedSkillPoints.entries) {
      final skillTypeName = entry.key;
      final skillType = SkillType.parse(skillTypeName);
      writeByte(skillType.index); // skill type index
      writeUInt16(entry.value); // skill type points
    }

    final damage = data?.tryGetDouble(AmuletField.Damage);
    final level = data?.tryGetInt(AmuletField.Level);
    final itemQualityIndex = data?.tryGetInt(AmuletField.Item_Quality);

    if (damage != null) {
      writeTrue();
      writeDecimal(damage);
    } else {
      writeFalse();
    }

    tryWriteUInt16(level);
    tryWriteByte(itemQualityIndex);
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
  SkillType get skillTypeRight => skillSlots[skillSlotIndex];

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

  @override
  void setSkillActiveLeft(bool value) {
    if (deadOrBusy) return;

    if (value && validateSkillType(skillTypeLeft)){
      super.setSkillActiveLeft(value);
      return;
    }
    if (!value && validateSkillType(skillTypeRight)){
      super.setSkillActiveLeft(value);
      return;
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

  double get equippedWeaponDamage =>
      equippedWeapon?.damage ?? 0;

  double getSkillTypeRange(SkillType skillType) =>
      switch (skillType.casteType) {
        CasteType.Passive => skillType.range,
        CasteType.Caste => skillType.range,
        CasteType.Bow => equippedWeaponRange?.ranged,
        CasteType.Staff => equippedWeaponRange?.ranged,
        CasteType.Sword => equippedWeaponRange?.melee,
        CasteType.Melee => equippedWeaponRange?.melee,
      } ?? 0;

  double getSkillTypeRadius(SkillType skillType) {
     switch (skillType){
       case SkillType.Explode:
         return 50;
       default:
         return 0;
     }
  }

  int getSkillTypeMagicCost(SkillType skillType) => skillType.magicCost;

  WeaponRange? get equippedWeaponRange {
    return equippedWeapon?.amuletItem.range;
  }

  WeaponClass? get equippedWeaponClass {
      final weaponType = equippedWeapon?.amuletItem.subType;
      if (weaponType == null){
        return null;
      }
      return WeaponClass.fromWeaponType(weaponType);
  }

  int getSkillTypeLevelAssigned(SkillType skillType){
      if (skillTypeAssignedToSkillSlot(skillType)){
        return getSkillTypeLevel(skillType);
      }
      return 0;
  }

  /// returns a number between 0.0 and 1.0
  double getAssignedSkillTypeLevelI(SkillType skillType) =>
      getSkillTypeLevelAssigned(skillType) / SkillType.Max_Level;

  int getSkillTypeLevel(SkillType skillType){
     var total = 0;
     total += equippedWeapon?.skillPoints[skillType] ?? 0;
     total += equippedHelm?.skillPoints[skillType] ?? 0;
     total += equippedArmor?.skillPoints[skillType] ?? 0;
     total += equippedShoes?.skillPoints[skillType] ?? 0;
     return min(total, SkillType.Max_Level);
  }

  void writeSkillTypes() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Types);
    for (final skillType in SkillType.values){
      writeByte(skillType.index);
      writeUInt16(getSkillTypeLevel(skillType));
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
    return getSkillTypeLevel(skillType) > 0;
  }

  @override
  void setCharacterStateHurt({int duration = 10}) {
    super.setCharacterStateHurt(duration: duration);
    activeSkillActiveLeft();
  }

  int getSkillTypePerformDuration(SkillType skillType) =>
      skillType.casteSpeed?.duration ??
      this.equippedWeaponAttackSpeed?.duration ??
      (throw Exception('amuletPlayer.getSkillTypePerformDuration(skillType: $skillType)'));

  double get healthSteal =>
      SkillType.getHealthSteal(getSkillTypeLevelAssigned(SkillType.Vampire));

  double get magicSteal =>
      SkillType.getMagicSteal(getSkillTypeLevelAssigned(SkillType.Warlock));

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
    final attackSpeedLevel = getSkillTypeLevelAssigned(SkillType.Agility);
    final attackSpeedPerc = SkillType.getAttackSpeedPercentage(attackSpeedLevel);
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

  void writeEquippedWeaponRange() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon_Range);
    tryWriteByte(equippedWeapon?.amuletItem.range?.index);
  }

  void writeEquippedWeaponAttackSpeed() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon_Attack_Speed);
    tryWriteByte(equippedWeaponAttackSpeed?.index);
  }

  double get areaDamage =>
      getAssignedSkillTypeLevelI(SkillType.Area_Damage);

  double get chanceOfCriticalDamage =>
      SkillType.getPercentageCriticalHit(
          getSkillTypeLevelAssigned(SkillType.Critical_Hit)
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
      default:
        return false;
    }
  }

  void writeSkillSlots() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Slots);
    for (final skillSlot in skillSlots) {
      writeByte(skillSlot.index);
    }
  }

  void setSkillSlotValue({
    required int index,
    required SkillType skillType,
  }) {
    if (!skillSlots.isValidIndex(index)) {
      writeGameError(GameError.Invalid_Skill_Slot_Index);
      return;
    }

    if (skillType != SkillType.None) {

      if (skillType != SkillType.None && getSkillTypeLevel(skillType) <= 0) {
        writeGameError(GameError.Skill_Type_Locked);
        return;
      }

      final previousSkillTypeIndex = getSkillTypeSlotIndex(skillType);

      if (previousSkillTypeIndex != null) {
        final existingSkillAtIndex = skillSlots[index];
        skillSlots[previousSkillTypeIndex] = existingSkillAtIndex;
      }
    }

    skillSlots[index] = skillType;
    notifySkillSlotsDirty();
  }

  void writeSkillSlotIndex(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Slot_Index);
    writeByte(skillSlotIndex);
  }

  void setSkillSlotIndex(int value) {

    if (dead) return;
    if (busy && !skillActiveLeft) return;

    if (!skillSlots.isValidIndex(value)) {
      writeGameError(GameError.Invalid_Skill_Slot_Index);
      return;
    };
    skillSlotIndex = value;
    writeSkillSlotIndex();
  }

  @override
  double get magicPercentage => (magic.percentageOf(maxMagic)).clamp01();

  void writeConsumableSlots(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Consumable_Slots);

    for (var i = 0; i < consumableSlots.length; i++){
      writeInt16(consumableSlots[i]?.index ?? -1);
    }
  }

  void consumeSlot(int index) {
     if (!consumableSlots.isValidIndex(index)){
       writeGameError(GameError.Invalid_Consumable_Index);
       return;
     }

     final amuletItem = consumableSlots[index];
     if (amuletItem == null){
       writeGameError(GameError.Consumable_Empty);
       return;
     }

     consumeAmuletItem(amuletItem);
     setConsumableSlot(index: index, amuletItem: null);
  }

  void consumeAmuletItem(AmuletItem amuletItem){
    switch (amuletItem){
      case AmuletItem.Consumable_Potion_Health:
        health += 10;
        break;
      case AmuletItem.Consumable_Potion_Magic:
        magic += 10;
        break;
      default:
        throw Exception();
    }

    writeAmuletItemConsumed(amuletItem);
  }

  void writeAmuletItemConsumed(AmuletItem amuletItem){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Amulet_Item_Consumed);
    writeAmuletItem(amuletItem);
  }

  void dropConsumable(int index) {
    if (!consumableSlots.isValidIndex(index)){
      writeGameError(GameError.Invalid_Consumable_Index);
      return;
    }

    final amuletItem = consumableSlots[index];
    if (amuletItem == null){
      writeGameError(GameError.Consumable_Empty);
      return;
    }

    setCharacterStateChanging();
    setConsumableSlot(index: index, amuletItem: null);
    spawnAmuletItemObject(
      AmuletItemObject(amuletItem: amuletItem, skillPoints: {})
    );
    writeAmuletItemDropped(amuletItem);
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

    if (!skillTypeUnlocked(skillType)){
      writeGameError(GameError.Skill_Type_Locked);
      return;
    }

    final slotIndex = getSkillTypeSlotIndex(skillType);

    if (slotIndex != null) {
      clearSkillSlot(slotIndex);
    }

    setSkillSlotValue(
        index: skillSlotIndex,
        skillType: skillType,
    );
  }

  void clearSkillSlot(int index) =>
      assignSkillSlot(index, SkillType.None);

  void assignSkillSlot(int index, SkillType skillType){
    skillSlots[index] = skillType;
    notifySkillSlotsDirty();
  }

  void spawnRandomAmuletItem() =>
      spawnAmuletItemObject(
          amuletGame.generateAmuletItemObject(
             amuletItem: randomItem(AmuletItem.values),
             level: randomInt(1, 99),
             itemQuality: randomItem(ItemQuality.values),
          )
      );

  void pickupAmuletItem() {
    final item = collectableAmuletItemObject;

    if (item == null) {
      writeGameError(GameError.Amulet_Item_Null);
      return;
    }
    amuletGame.onAmuletPlayerPickupGameObject(this, item);
  }

  void tryWriteByte(int? value) =>
      tryWrite(writeByte, value);

  void tryWriteUInt16(int? value) =>
      tryWrite(writeUInt16, value);

  void tryWrite<T>(Function(T t) write, T? value){
    if (value == null){
      writeFalse();
      return;
    }
    writeTrue();
    write(value);
  }
}

