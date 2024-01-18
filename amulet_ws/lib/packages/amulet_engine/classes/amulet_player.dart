
import 'dart:math';

import 'package:amulet_engine/classes/amulet_fiend.dart';
import 'package:amulet_engine/classes/amulet_gameobject.dart';

import '../maps/map_item_type_to_slot_type.dart';
import '../packages/isomeric_engine.dart';
import '../mixins/src.dart';
import '../packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import '../json/src.dart';
import '../packages/isometric_engine/packages/common/src/amulet/quests/quest_tutorials.dart';
import 'amulet.dart';
import 'amulet_game.dart';
import 'amulet_npc.dart';
import 'games/amulet_game_tutorial.dart';
import 'talk_option.dart';

class AmuletPlayer extends IsometricPlayer with
    Equipment,
    Magic
{
  static const Data_Key_Dead_Count = 'dead';

  var baseHealth = 10;
  var baseMagic = 10;
  var baseRegenMagic = 1;
  var baseRegenHealth = 1;
  var baseRunSpeed = 1.0;

  var activePowerX = 0.0;
  var activePowerY = 0.0;
  var activePowerZ = 0.0;

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
  }) : super(game: amuletGame, health: 10, team: AmuletTeam.Human) {
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
  }

  @override
  set magic(int value) {
    value = value.clamp(0, maxMagic);
    super.magic = value;
    writePlayerMagic();
  }

  int get deathCount => data.tryGetInt(Data_Key_Dead_Count) ?? 0;

  set deathCount(int value) => data.setInt(Data_Key_Dead_Count, value);

  QuestMain get questMain {
    final questMainIndex = data.tryGetInt('quest_main') ?? 0;
    return QuestMain.values[questMainIndex];
  }

  AmuletItem? get activeAmuletItemSlot {
     switch (activeSlotType){
       case SlotType.Helm:
         return equippedHelm;
       case SlotType.Armor:
         return equippedArmor;
       case SlotType.Shoes:
         return equippedShoes;
       default:
         return null;
     }
  }

  set questMain (QuestMain value){
    data.setInt('quest_main', value.index);
    writeQuestMain(value);
  }

  @override
  set aimTarget(Collider? value) {
    if (
    noWeaponEquipped &&
        value is GameObject &&
        value.hitable
    ){
      return;
    }
    super.aimTarget = value;
  }

  bool get noWeaponEquipped => equippedWeapon == null;

  Amulet get amulet => amuletGame.amulet;

  @override
  int get weaponType => equippedWeapon?.subType ?? WeaponType.Unarmed;

  @override
  int get weaponDamage => randomInt(weaponDamageMin, weaponDamageMax + 1);

  @override
  double get weaponRange => (activeAmuletItemSlot ?? equippedWeapon)?.range ?? 0;

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

  set tutorialObjective(QuestTutorial tutorialObjective){
    data['tutorial_objective'] = tutorialObjective.name;
  }

  QuestTutorial get tutorialObjective {
    final index = data['tutorial_objective'];

    if (index == null) {
      return QuestTutorial.values.first;
    }

    if (index is int) {
      return QuestTutorial.values[index];
    }

    if (index is String) {
      for (final objective in QuestTutorial.values) {
        if (objective.name == index) {
          return objective;
        }
      }
      throw Exception('could not find objective $name');
    }

    throw Exception();
  }

  int get weaponDamageMin {
    return equippedWeapon?.damageMin ?? 0;
  }

  int get weaponDamageMax {
    return equippedWeapon?.damageMax ?? 0;
  }

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
    writeWeaponDamage();
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

  void writeWeaponDamage() {
    if (
      cacheWeaponDamageMin == weaponDamageMin &&
      cacheWeaponDamageMax == weaponDamageMax &&
      cacheWeaponRange == weaponRange
    ) return;
    cacheWeaponDamageMin = cacheWeaponDamageMin;
    cacheWeaponDamageMax = cacheWeaponDamageMax;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Player_Weapon_Damage);
    writeUInt16(weaponDamageMin);
    writeUInt16(weaponDamageMax);
    writeUInt16(weaponRange.toInt());
  }

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

  void deactivateSlotType() => setActiveSlotType(null);

  void setActiveSlotType(SlotType? value) {
    activeSlotType = value;
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Active_Slot_Type);
    if (value == null) {
      writeFalse();
      return;
    }
    writeTrue();
    writeByte(value.index);
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
    weaponType = equippedWeapon?.subType ?? WeaponType.Unarmed;
    equipmentDirty = false;
    helmType = equippedHelm?.subType ?? HelmType.None;
    armorType = equippedArmor?.subType ?? 0;
    shoeType = equippedShoes?.subType ?? ShoeType.None;

    writeEquipped();
    writePlayerHealth();
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

  @override
  void update() {
    super.update();
    updateActiveAbility();
  }

  void updateActiveAbility() {

    if (activeAmuletItemSlot == null){
      return;
    }

    final activeAmuletItem = activeAmuletItemSlot;

    if (activeAmuletItem == null){
      return;
    }

    final skillType = activeAmuletItem.skillType;

    if (skillType == null){
      return;
    }

    if (skillType.casteType == CasteType.Positional) {
      final mouseDistance = getMouseDistance();
      final maxRange = activeAmuletItem.range ?? (throw Exception());
      if (mouseDistance <= maxRange){
        activePowerX = mouseSceneX;
        activePowerY = mouseSceneY;
        activePowerZ = mouseSceneZ;
      } else {
        final mouseAngle = getMouseAngle() + pi;
        activePowerX = x + adj(mouseAngle, maxRange);
        activePowerY = y + opp(mouseAngle, maxRange);
        activePowerZ = z;
      }
      writeActivePowerPosition();
    }
  }

  void writeActivePowerPosition() {
    writeByte(NetworkResponse.Amulet);
    writeByte(NetworkResponseAmulet.Active_Power_Position);
    writeDouble(activePowerX);
    writeDouble(activePowerY);
    writeDouble(activePowerZ);
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

  @override
  void clearAction() {
    super.clearAction();
    deactivateSlotType();
  }

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

  bool flagNotSet(String name) => !flagSet(name);

  bool flagSet(String name)=> data.containsKey(name);

  /// to run a piece of code only a single time
  /// the first time a flag name is entered it will return true
  /// however any time after that if the same flag name is entered
  /// the return will be false
  bool readOnce(String name){
    if (!data.containsKey(name)){
      data[name] = true;
      return true;
    }
    return false;
  }

  int getInt(String name) => data[name] as int;

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

  bool objectiveCompleted(String name){
    var objectives = data['objectives'];

    if (objectives == null){
       return false;
    }

    if (objectives is! List){
      throw Exception('objectives is! List');
    }

    return objectives.contains(name);
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

    if (noWeaponEquipped){
      return;
    }

    final amuletItem = equippedWeapon;

    if (amuletItem == null){
      return;
    }

    final performDuration = amuletItem.performDuration;

    if (performDuration == null){
      throw Exception('performDuration is null: $amuletItem');
    }

    final subType = amuletItem.subType;
    this.weaponDamage = AmuletGame.getAmuletItemDamage(amuletItem);

    useWeaponType(
      weaponType: subType,
      duration: performDuration,
    );
  }

  void useWeaponType({
    required int weaponType,
    required int duration,
  }) {

    if (const[
      WeaponType.Shortsword,
      WeaponType.Broadsword,
      WeaponType.Staff,
      WeaponType.Sword_Heavy_Sapphire,
    ].contains(weaponType)) {
      setCharacterStateStriking(
        duration: duration,
      );
      return;
    }

    if (const[
      WeaponType.Bow,
    ].contains(weaponType)){
      setCharacterStateFire(
        duration: duration,
      );
      return;
    }

    throw Exception(
        'amuletPlayer.attack() - weapon type not implemented ${WeaponType
            .getName(weaponType)}'
    );
  }

  void useActivatedPower() {
    if (deadInactiveOrBusy) {
      return;
    }

    final amuletItemSlot = this.activeAmuletItemSlot;

    if (amuletItemSlot != null){
      onAmuletItemUsed(amuletItemSlot);
    }
  }

  void onAmuletItemUsed(AmuletItem amuletItem) {

    // final dependency = amuletItem.dependency;
    //
    // if (dependency != null) {
    //   final equippedWeaponAmuletItem = equippedWeapon;
    //
    //   if (equippedWeaponAmuletItem == null || equippedWeaponAmuletItem.subType != dependency) {
    //     writeGameError(GameError.Weapon_Required);
    //     return;
    //   }
    // }

    final performDuration = amuletItem.performDuration;

    if (performDuration == null) {
      throw Exception('performDuration == null: ${amuletItem}');
    }

    final magicCost = amuletItem.skillMagicCost;

    if (magicCost != null) {
      if (magicCost > magic){
        writeGameError(GameError.Insufficient_Magic);
      }
      magic -= magicCost;
    }


    switch (amuletItem.skillType?.casteType) {
      case CasteType.Self:
        setCharacterStateCasting(
          duration: performDuration,
        );
        break;
      case CasteType.Targeted_Enemy:
        if (target == null) {
          deactivateSlotType();
          return;
        }
        useWeaponType(
          weaponType: amuletItem.subType,
          duration: performDuration,
        );
        // useWeaponType(
        //   weaponType: dependency ?? amuletItem.subType,
        //   duration: performDuration,
        // );
        break;
      case CasteType.Targeted_Ally:
        if (target == null) {
          deactivateSlotType();
          return;
        }
        setCharacterStateCasting(
          duration: performDuration,
        );
        break;
      case CasteType.Positional:
        setCharacterStateCasting(
          duration: performDuration,
        );
        break;
      case CasteType.Instant:
        break;
      case CasteType.Directional:
        lookAtMouse();
        setCharacterStateCasting(
          duration: performDuration,
        );
        break;
      case null:
        break;
      case CasteType.Passive:
        break;
    }
  }

  void useSlotTypeAtIndex(SlotType slotType, int index) {
    if (index < 0) {
      return;
    }

    switch (slotType){

      default:
        setActiveSlotType(slotType);
        break;
    }
  }

  void clearActivatedPowerIndex(){
    deactivateSlotType();
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
    questMain = QuestMain.values[quest.index + 1];
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

  void selectItemType(int itemType) =>
      setActiveSlotType(mapItemTypeToSlotType(itemType));
}
