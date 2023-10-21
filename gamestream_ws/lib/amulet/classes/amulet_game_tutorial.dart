
import 'package:gamestream_ws/amulet/src.dart';
import 'package:gamestream_ws/gamestream/amulet.dart';
import 'package:gamestream_ws/isometric/src.dart';
import 'package:gamestream_ws/packages.dart';

import 'fiend_type.dart';


class AmuletGameTutorial extends AmuletGame {

  static const keysGuideSpawn0 = 'guide_spawn_0';
  static const keysGuideSpawn1 = 'guide_spawn_1';
  static const keysPlayerSpawn = 'player_spawn_00';
  static const keysDoor01 = 'door01';
  static const keysFiend01 = 'fiend01';
  static const keysFiend02 = 'fiend02';

  static const flagsDoor01Opened = 'door01_opened';

  final scripts = <AmuletPlayerScript>[];

  late final Character guide;
  Character? fiend01;

  AmuletGameTutorial({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required super.name,
    required super.fiendTypes,
  }) {
    guide = buildAmuletNpcGuide();
    add(guide);
  }

  AmuletNpc buildAmuletNpcGuide() => AmuletNpc(
    name: 'Guide',
    interact: onInteractedWithGuide,
    x: 1000,
    y: 1400,
    z: 25,
    team: AmuletTeam.Human,
    characterType: CharacterType.Kid,
    health: 50,
    weaponType: WeaponType.Unarmed,
    weaponDamage: 1,
    weaponRange: 50,
    weaponCooldown: 50,
    invincible: true,
  )
    ..complexion = 20
    ..legsType = LegType.Leather
    ..bodyType = BodyType.Leather_Armour;

  int getSceneKey(String name) =>
      scene.keys[name] ?? (throw Exception('amuletGameTutorial.getKey("$name") is null'));

  void onNodeChanged(int index){
    final players = this.players;
    final scene = this.scene;
    for (final player in players) {
      player.writeNode(
        index: index,
        type: scene.types[index],
        shape: scene.shapes[index],
      );
    }
  }

  @override
  void update() {
    super.update();
    updateScripts();
  }

  void updateScripts() {
    final scripts = this.scripts;
    for (var i = 0; i <scripts.length; i++){
      scripts[i].update();
    }
  }

  void onInteractedWithGuide(AmuletPlayer player){

    if (objectiveActiveSpeakToGuide(player)) {
      objectiveApplySpeakToGuide(player);
      return;
    }
  }

  bool objectiveActiveSpeakToGuide(AmuletPlayer player) => player.readFlag('guide_met');

  void objectiveApplySpeakToGuide(AmuletPlayer player) {
    player.cameraTarget = guide;
    actionSetCameraTargetGuide(player);
    player.talk('danger does lie ahead');
    player.onInteractionOver = actionSpawnWeaponAtGuide;
  }

  void actionSetCameraTargetGuide(AmuletPlayer player) {
    actionSetCameraTarget(player, guide);
  }

  void actionSpawnWeaponAtGuide() {
    spawnAmuletItem(
        item: AmuletItem.Weapon_Rusty_Old_Sword,
        x: guide.x,
        y: guide.y,
        z: guide.z,
    );
    actionDeactivateGuide();
  }

  void actionDeactivateGuide() {
    deactivate(guide);
  }

  @override
  void customOnCharacterKilled(Character target, src) {
    super.customOnCharacterKilled(target, src);

    if (target == fiend01) {
      onCharacterKilledFiend01(target);
    }
  }

  void onCharacterKilledFiend01(Character target) {
    actionSpawnAmuletItemSpellHeal(target);
  }

  void actionSpawnAmuletItemSpellHeal(Character target) {
    spawnAmuletItem(
        item: AmuletItem.Spell_Heal,
        x: target.x,
        y: target.y,
        z: target.z,
        deactivationTimer: -1,
    );
  }

  @override
  void onPlayerJoined(AmuletPlayer player) {
    refreshPlayerGameState(player);
  }

  @override
  void customOnPlayerRevived(AmuletPlayer player) {
    super.customOnPlayerRevived(player);
    refreshPlayerGameState(player);
  }

  void refreshPlayerGameState(AmuletPlayer player) {

    if (player.flagSet(flagsDoor01Opened)){
      actionOpenDoor01(player);
    } else {
      actionCloseDoor01();
    }

    if (!player.flagSet('fiend01_defeated')){
      actionInstantiateFiend01();
    }

    if (player.readFlag('initialized')) {
      actionInitializeNewPlayer(player);
    }

    if (player.readFlag('initialized')) {
      actionInitializeNewPlayer(player);
    }

    if (player.readFlag('introduction')){

      final script = AmuletPlayerScript(player);

      script
        .playerControlsDisabled()
        .movePlayerToSceneKey(keysPlayerSpawn)
        .movePositionToSceneKey(guide, keysGuideSpawn0)
        .wait(seconds: 2)
        .cameraSetTarget(guide)
        .talk(
          'greetings other.'
          'one is here to guide another.'
          'left click the mouse to move.'
        )
        .movePositionToSceneKey(guide, keysGuideSpawn1)
        .playerControlsEnabled()
        .cameraClearTarget()
      ;

      scripts.add(script);

      // actionPlayerControlsDisabled(player);
      // actionMovePlayerToSpawn01(player);
      // actionMoveGuideToGuideSpawn0();
      // actionFaceOneAnother(player, guide);

      // addJob(seconds: 2, action: () {
      //   actionCameraTargetGuide(player);
      //   actionPlayerTalkIntroduction(player);
      //
      //   player.onInteractionOver = () {
      //     addJob(seconds: 1, action: () {
      //       actionMoveGuideToGuideSpawn1();
      //       actionPlayerControlsEnabled(player);
      //       actionClearCameraTarget(player);
      //     });
      //   };
      // });
      return;
    }
  }

  void actionPlayerTalkIntroduction(AmuletPlayer player) {
    player.talk(
      'greetings other.'
      'one is here to guide another.'
      'left click the mouse to move.'
    );
  }

  void actionMoveGuideToGuideSpawn0() {
    actionMoveOxToSceneKey(keysGuideSpawn0);
  }

  void actionMoveGuideToGuideSpawn1() {
    actionMoveOxToSceneKey(keysGuideSpawn1);
  }

  void actionMoveOxToSceneKey(String sceneKey){
    actionMovePositionToSceneKey(guide, sceneKey);
  }

  void actionMovePositionToSceneKey(Position position, String sceneKey){
    movePositionToIndex(position, getSceneKey(sceneKey));
  }

  void actionWritePlayerPositionAbsolute(AmuletPlayer player) {
    player.writePlayerPositionAbsolute();
  }

  void actionInstantiateFiend01() {
    fiend01 = spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen_01,
        index: getSceneKey(keysFiend01),
    )
      ..spawnLootOnDeath = false
      ..respawnDurationTotal = -1;
  }

  void actionCloseDoor01() {
     setNode(
      nodeIndex: getSceneKey(keysDoor01),
      nodeType: NodeType.Wood,
      nodeOrientation: NodeOrientation.Half_West,
    );
  }

  void actionMovePlayerToSpawn01(AmuletPlayer player) {
    final playerSpawn01 = scene.getKey(keysPlayerSpawn);
    actionMovePositionToIndex(player, playerSpawn01);
    actionWritePlayerPositionAbsolute(player);
  }

  void actionInitializeNewPlayer(AmuletPlayer player) {
    for (final weapon in player.weapons){
      weapon.amuletItem = null;
    }
    player.healthBase = 15;
    player.equipBody(AmuletItem.Armor_Leather_Basic, force: true);
    player.equipLegs(AmuletItem.Pants_Travellers, force: true);
    player.health = player.maxHealth;
  }

  @override
  void onAmuletItemUsed(AmuletPlayer player, AmuletItem amuletItem) {
    if (
      amuletItem == AmuletItem.Spell_Heal &&
      player.readFlag('use_spell_heal')
    ) {

      actionPlayerControlsDisabled(player);
      actionSpawnFiends02();

      addJob(
          seconds: 3,
          action: clearDoor02,
      );
    }
  }

  void actionSpawnFiends02() {
    final fiend02Index = getSceneKey(keysFiend02);
    for (var i = 0; i < 2; i++) {
      const shiftRadius = 10;
      spawnFiendTypeAtIndex(
        fiendType: FiendType.Fallen_01,
        index: fiend02Index,
      )
        ..spawnLootOnDeath = false
        ..respawnDurationTotal = -1
        ..x += giveOrTake(shiftRadius)
        ..y += giveOrTake(shiftRadius);
    }
  }

  void clearDoor02() => setNodeEmpty(getSceneKey('door02'));

  void refreshSceneState(){

  }

  void actionOpenDoor01(AmuletPlayer player) {
    actionPlayerControlsDisabled(player);
    final door01Index = scene.getKey(keysDoor01);
    final door01Position = Position();
    scene.movePositionToIndex(door01Position, door01Index);
    player.cameraTarget = door01Position;

    addJob(seconds: 2, action: (){
      player.readFlag(flagsDoor01Opened);
      setNodeEmpty(getSceneKey(keysDoor01));
      addJob(seconds: 2, action: (){
        actionClearCameraTarget(player);
        actionPlayerControlsEnabled(player);
      });
    });
  }

  void actionFaceOneAnother(Character a, Character b) {
     a.face(b);
     b.face(a);
  }

  void actionPlayerControlsDisabled(AmuletPlayer player) {
     player.controlsEnabled = false;
  }

  void actionPlayerControlsEnabled(AmuletPlayer player) {
     player.controlsEnabled = true;
  }

  void actionClearCameraTarget(AmuletPlayer player){
    actionSetCameraTarget(player, null);
  }

  void actionSetCameraTarget(AmuletPlayer player, Position? target) {
      player.cameraTarget = target;
  }

  @override
  void onAmuletItemAcquired(AmuletPlayer player, AmuletItem amuletItem) {
    if (amuletItem == AmuletItem.Weapon_Rusty_Old_Sword){
      if (player.readFlag('acquired_weapon_sword')){
        actionOpenDoor01(player);
      }
      return;
    }

    if (amuletItem == AmuletItem.Spell_Heal){
      if (player.readFlag('acquired_spell_heal')){
        actionOpenDoor01(player);
        actionPlayerControlsDisabled(player);
        actionMoveGuideToFiend01();
        actionCameraTargetGuide(player);

        addJob(seconds: 2, action: (){
          actionActivateGuide();
          player.talk(
              'one has acquired a healing spell.'
              'press the "Spell Heal" icon at the bottom of the screen.'
              'each item has a limited number of charges.'
              'charges replenish over time.'
          );
          player.onInteractionOver = () {
            actionDeactivateGuide();
            actionClearCameraTarget(player);
            actionPlayerControlsEnabled(player);
          };
        });
      }
      return;
    }
  }

  void actionActivateGuide() {
    activateCollider(guide);
  }

  void actionCameraTargetGuide(AmuletPlayer player) {
    actionSetCameraTargetGuide(player);
  }

  void actionMoveGuideToFiend01() {
    actionMoveOxToSceneKey(keysFiend01);
  }
}

class AmuletPlayerScript {
  final AmuletPlayer player;
  final actions = <Function()>[];
  var index = 0;
  var available = false;

  AmuletPlayerScript(this.player);

  void update(){

    if (available){
      return;
    }

    if (index < 0 || index >= actions.length){
      actions.clear();
      index = -1;
      available = true;
      return;
    }

    final action = actions[index];
    if (action.call() != false){
      index++;
    }
  }

  AmuletPlayerScript wait({int seconds = 0}) {
    final frames = seconds * Amulet.Frames_Per_Second;
    final endFrame = player.amuletGame.frame + frames;
    return add(() => player.amuletGame.frame >= endFrame);
  }

  AmuletPlayerScript add(Function() action){
    actions.add(action);
    return this;
  }

  AmuletPlayerScript playerControlsDisabled() => playerControls(false);

  AmuletPlayerScript playerControlsEnabled() => playerControls(true);

  AmuletPlayerScript playerControls(bool enabled) =>
      add(() {
        player.controlsEnabled = enabled;
      });

  AmuletPlayerScript movePlayerToSceneKey(String sceneKey) =>
      movePositionToSceneKey(player, sceneKey);

  AmuletPlayerScript movePositionToSceneKey(Position position, String sceneKey) {
    final scene = player.amuletGame.scene;
    final index = scene.getKey(sceneKey);
    return movePositionToIndex(position, index);
  }

  AmuletPlayerScript movePositionToIndex(Position position, int index) => add(() {
      final scene = player.amuletGame.scene;
      position.x = scene.getIndexX(index);
      position.y = scene.getIndexY(index);
      position.z = scene.getIndexZ(index);
    });

  AmuletPlayerScript cameraSetTarget(Position? position) =>
      add(() {
        player.cameraTarget = position;
      });

  AmuletPlayerScript talk(String text, {List<TalkOption>? options}) {
    var initialized = false;
    return add(() {
      if (initialized) {
        return !player.interacting;
      }
      player.talk(text, options: options);
      initialized = true;
      return false;
    });
  }

  AmuletPlayerScript cameraClearTarget() => cameraSetTarget(null);
}