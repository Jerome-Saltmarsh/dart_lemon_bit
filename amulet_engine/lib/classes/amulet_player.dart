
import 'dart:math';

import 'package:amulet_engine/src.dart';
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

  final sceneShrinesUsed = <AmuletScene, List<int>> {};
  final skillSlots = List.generate(4, (index) => SkillType.None);
  final consumableSlots = List<AmuletItem?>.generate(4, (index) => null);

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
      equippedWeapon?.attackSpeed;

  @override
  set magic(int value) {
    value = value.clamp(0, maxMagic);
    super.magic = value;
    writePlayerMagic();
  }

  int get masterySword {
    var total = 0;
    total += equippedWeapon?.masterySword ?? 0;
    total += equippedHelm?.masterySword ?? 0;
    total += equippedArmor?.masterySword ?? 0;
    total += equippedShoes?.masterySword ?? 0;
    return total;
  }

  int get masteryStaff {
    var total = 0;
    total += equippedWeapon?.masteryStaff ?? 0;
    total += equippedHelm?.masteryStaff ?? 0;
    total += equippedArmor?.masteryStaff ?? 0;
    total += equippedShoes?.masteryStaff ?? 0;
    return total;
  }

  int get masteryBow {
    var total = 0;
    total += equippedWeapon?.masteryBow ?? 0;
    total += equippedHelm?.masteryBow ?? 0;
    total += equippedArmor?.masteryBow ?? 0;
    total += equippedShoes?.masteryBow ?? 0;
    return total;
  }

  int get masteryCaste {
    var total = 0;
    total += equippedWeapon?.masteryCaste ?? 0;
    total += equippedHelm?.masteryCaste ?? 0;
    total += equippedArmor?.masteryCaste ?? 0;
    total += equippedShoes?.masteryCaste ?? 0;
    return total;
  }

  void setQuestMain (QuestMain value){
    this.questMain = value;
    writeQuestMain(value);
  }

  bool get noWeaponEquipped => equippedWeapon == null;

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
    var total = baseHealth;
    total += equippedWeapon?.maxHealth ?? 0;
    total += equippedHelm?.maxHealth ?? 0;
    total += equippedArmor?.maxHealth ?? 0;
    total += equippedShoes?.maxHealth ?? 0;
    return total;
  }

  @override
  int get maxMagic {
    var total = baseMagic;
    total += equippedWeapon?.maxMagic ?? 0;
    total += equippedHelm?.maxMagic ?? 0;
    total += equippedArmor?.maxMagic ?? 0;
    total += equippedShoes?.maxMagic ?? 0;
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
    // total += equippedWeapon?.runSpeed ?? 0;
    // total += equippedHelm?.runSpeed ?? 0;
    // total += equippedArmor?.runSpeed ?? 0;
    // total += equippedShoes?.runSpeed ?? 0;
    return total;
  }

  int get agility {
    var total = 0;
    total += equippedWeapon?.agility ?? 0;
    total += equippedHelm?.agility ?? 0;
    total += equippedArmor?.agility ?? 0;
    total += equippedShoes?.agility ?? 0;
    return total;
  }

  @override
  void writePlayerGame() {
    cleanEquipment();
    writeCameraTarget();
    writeRegenMagic();
    writeRegenHealth();
    writeRunSpeed();
    writeAgility();
    writePerformFrameVelocity();
    writeHealthSteal();
    writeMagicSteal();

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
    if (cacheAgility == agility) return;
    cacheAgility = agility;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Agility);
    writeUInt16(agility);
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
    const spawnDistance = 20.0;
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
    removeInvalidSkillSlots();
    checkAssignedSkillTypes();
    checkActiveSlotType();
    writeEquipped();
    writePlayerHealth();
    writePlayerMagic();
    writeSkillTypes();
    writeCharacteristics();
    writeEquippedWeaponRange();
    writeEquippedWeaponAttackSpeed();
    writeEquippedWeaponAreaDamage();
    writePlayerCriticalHitPoints();
    writeSkillActiveLeft();
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

  void updateCastePosition() {
    final skillType = skillActive;
    final mouseDistance = getMouseDistance();
    final maxRange = getSkillTypeRange(skillType);

    if (maxRange == null){
      return;
    }

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

    if (value.isConsumable) {
      final availableIndex = getEmptyConsumableSlotIndex();
      if (availableIndex == null){
        writeGameError(GameError.Potion_Slots_Full);
        return;
      }
      setConsumableSlot(index: availableIndex, amuletItem: value);
      writeAmuletItemEquipped(value);
      return;
    }

    final currentlyEquipped = getEquippedAmuletItem(slotType: value.slotType);
    if (currentlyEquipped != null) {
      dropSlotType(currentlyEquipped.slotType);
    }

    switch (value.slotType){
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

    final skillType = value.skillType;

    if (skillType != null && !skillTypeAssignedToSkillSlot(skillType)) {
        tryToAssignSkillTypeToEmptySlot(skillType);
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

  void notifySkillSlotsDirty() {
    skillSlotsDirty = true;
  }


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

      spawnAmuletItem(equippedAmuletItem);
      switch (equippedAmuletItem.slotType) {
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

  AmuletItem? getEquippedAmuletItem({required SlotType slotType}) =>
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
    writeOptionsSetTimeVisible(game is! AmuletGameTutorial);
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

     final aimTarget = this.aimTarget;
     if (aimTarget is! GameObject){
       writeFalse();
       return;
     }

    final amuletItem = getGameObjectAmuletItem(aimTarget);

     if (amuletItem == null){
       writeFalse();
       return;
     }

    writeTrue();
    writeAmuletItem(amuletItem);
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

  bool get equippedWeaponBow => equippedWeapon?.isWeaponBow ?? false;

  bool get equippedWeaponStaff => equippedWeapon?.isWeaponStaff ?? false;

  bool get equippedWeaponSword => equippedWeapon?.isWeaponSword ?? false;

  bool get equippedWeaponMelee => equippedWeaponSword || equippedWeaponStaff;

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
       return 0;
    }
    return damage;
  }

  int getSkillTypeDamageDivider(SkillType skillType, int divider){

    if (skillType == SkillType.Strike) {
      return equippedWeaponDamage + masterySword ~/ divider;
    }

    if (const [
      SkillType.Shoot_Arrow,
      SkillType.Split_Shot,
      SkillType.Ice_Arrow,
      SkillType.Fire_Arrow,
    ].contains(skillType)) {
      return equippedWeaponDamage + masteryBow ~/ divider;
    }

    switch (skillType) {
      case SkillType.Mighty_Strike:
        return (equippedWeaponDamage + masterySword ~/ divider) * 2;
      case SkillType.Frostball:
        return 5 + masteryStaff ~/ divider;
      case SkillType.Fireball:
        return 5 + masteryStaff ~/ divider;
      case SkillType.Explode:
        return 10 + masteryStaff ~/ divider;
      default:
        return 0;
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
      switch (skillType.casteType) {
        CasteType.Caste => skillType.range,
        CasteType.Bow => equippedWeaponRange?.ranged,
        CasteType.Staff => equippedWeaponRange?.melee,
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

  WeaponRange? get equippedWeaponRange => equippedWeapon?.range;

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
      writeUInt16((getSkillTypeRange(skillType) ?? 0).toInt());
      // writeUInt16(getSkillTypePerformDuration(skillType).toInt());
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
    writeUInt16(masterySword);
    writeUInt16(masteryStaff);
    writeUInt16(masteryBow);
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
       SlotType.Consumable => null,
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
      skillType.casteSpeed?.duration ??
      this.equippedWeaponAttackSpeed?.duration ??
      (throw Exception('amuletPlayer.getSkillTypePerformDuration(skillType: $skillType)'));

  int getSkillTypeAmount(SkillType skillType) {
    switch (skillType) {
      case SkillType.Split_Shot:
        return AmuletSettings.Amount_Skill_Type_Split_Shot_Base +
            (masteryBow * AmuletSettings.Ratio_Skill_Type_Split_Shot_Amount).toInt();
      case SkillType.Heal:
        return 5 + (masteryCaste * 2);
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
    total += equippedWeapon?.healthSteal ?? 0;
    total += equippedHelm?.healthSteal ?? 0;
    total += equippedArmor?.healthSteal ?? 0;
    total += equippedShoes?.healthSteal ?? 0;
    return total;
  }

  int get magicSteal {
    var total = 0;
    total += equippedWeapon?.magicSteal ?? 0;
    total += equippedHelm?.magicSteal ?? 0;
    total += equippedArmor?.magicSteal ?? 0;
    total += equippedShoes?.magicSteal ?? 0;
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

  @override
  double get frameVelocity {
    if (actionFrame > 0){
      return performFrameVelocity;
    }
    return super.frameVelocity;
  }

  double get performFrameVelocity =>
      super.frameVelocity + (agility * AmuletSettings.Ratio_Frame_Velocity_Agility);

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

  void writeHealthSteal() {
     final healthSteal = this.healthSteal;
     if (healthSteal == cacheHealthSteal) return;

     cacheHealthSteal = healthSteal;
     writeByte(NetworkResponse.Amulet);
     writeByte(NetworkResponseAmulet.Player_Health_Steal);
     writeByte(healthSteal);
  }

  void writeMagicSteal() {
     final magicSteal = this.magicSteal;
     if (magicSteal == cacheMagicSteal) return;

     cacheMagicSteal = magicSteal;
     writeByte(NetworkResponse.Amulet);
     writeByte(NetworkResponseAmulet.Player_Magic_Steal);
     writeByte(magicSteal);
  }

  void writeEquippedWeaponRange() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon_Range);
    tryWriteByte(equippedWeapon?.range?.index);
  }

  void writeEquippedWeaponAttackSpeed() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon_Attack_Speed);
    tryWriteByte(equippedWeaponAttackSpeed?.index);
  }

  double get areaDamage {
    var total = 0.0;
    total += equippedWeapon?.areaDamage?.value ?? 0;
    total += equippedHelm?.areaDamage?.value ?? 0;
    total += equippedArmor?.areaDamage?.value ?? 0;
    total += equippedShoes?.areaDamage?.value ?? 0;
    return total;
  }

  double get chanceOfCriticalDamage =>
      totalCriticalHitPoints / AmuletSettings.Max_Critical_Hit_Points;

  int get totalCriticalHitPoints {
    var total = 0;
    total += equippedWeapon?.criticalHitPoints ?? 0;
    total += equippedHelm?.criticalHitPoints ?? 0;
    total += equippedArmor?.criticalHitPoints ?? 0;
    total += equippedShoes?.criticalHitPoints ?? 0;
    return total.clamp(0, AmuletSettings.Max_Critical_Hit_Points);
  }

  void writeEquippedWeaponAreaDamage() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon_Area_Damage);
    tryWriteByte(equippedWeaponAreaDamage?.index);
  }

  AreaDamage? get equippedWeaponAreaDamage => equippedWeapon?.areaDamage;

  void tryWriteByte(int? value){
    if (value == null){
      writeFalse();
      return;
    }
    writeTrue();
    writeByte(value);
  }

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
      throw Exception('amuletPlayer.setSkillSlotValue(index: $index, skillType: $skillType)');
    }
    skillSlots[index] = skillType;
    notifySkillSlotsDirty();
  }

  void writeSkillSlotIndex(){
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Skill_Slot_Index);
    writeByte(skillSlotIndex);
  }

  void setSkillSlotIndex(int value){
    if (value < 0 || value > 3) return;
    skillSlotIndex = value;
    writeSkillSlotIndex();
  }

  @override
  double get magicPercentage => maxMagic > 0 ? magic / maxMagic : 0;

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
    health += amuletItem.regenHealth ?? 0;
    magic += amuletItem.regenMagic ?? 0;
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

    setConsumableSlot(index: index, amuletItem: null);
    spawnAmuletItem(amuletItem);
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

}

