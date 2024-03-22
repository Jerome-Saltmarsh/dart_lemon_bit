
import 'dart:math';
import 'dart:typed_data';

import 'package:amulet_common/src.dart';
import 'package:amulet_server/classes/amulet_fiend.dart';
import 'package:amulet_server/isometric/consts/frames_per_second.dart';
import 'package:lemon_bit/src.dart';
import 'package:lemon_byte/src.dart';
import 'package:lemon_math/src.dart';

import '../consts/isometric_settings.dart';
import '../instances/encoder.dart';
import 'character.dart';
import 'collider.dart';
import 'edit_state.dart';
import 'gameobject.dart';
import 'isometric_game.dart';
import 'position.dart';
import 'scene.dart';

class IsometricPlayer extends Character with ByteWriter {

  static const Cache_Length = 250;

  var editEnabled = true;
  var controlsEnabled = true;
  var userId = "";
  var uuid = "";
  var _playerMode = PlayerMode.playing;
  var _cacheAimTargetHealthPercentage = 0.0;
  var _debugging = false;
  var mouseLeftDownDuration = 0;
  var mouseRightDownDuration = 0;
  var mouseRightDownIgnore = false;
  var _mouseLeftDown = false;
  var aimTargetActionPrevious = -1;
  var aimTargetAction = TargetAction.Run;

  var _previousCharacterState = -1;
  var weaponDurationPercentagePrevious = 0.0;
  var inputMode = InputMode.Keyboard;
  var screenLeft = 0.0;
  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var framesSinceClientRequest = 0;
  var sceneDownloaded = false;
  var initialized = false;
  var id = 0;
  var selectedColliderDirty = false;
  var gameTimeInMinutes = 0;
  var mouseX = 0.0;
  var mouseY = 0.0;
  var charactersIStart = 0;
  var charactersIEnd = 0;
  var positionCacheX = 0;
  var positionCacheY = 0;
  var positionCacheZ = 0;

  final cacheCharacterTypeAndTeam = Uint8List(Cache_Length);
  final cacheCharacterState = Uint8List(Cache_Length);
  final cacheHealthPerc = Uint8List(Cache_Length);
  final cacheDirection = Uint8List(Cache_Length);
  final cacheAnimationFrame = Uint8List(Cache_Length);
  final cacheAilments = Uint8List(Cache_Length);

  final cachePositionX = Int16List(Cache_Length);
  final cachePositionY = Int16List(Cache_Length);
  final cachePositionZ = Int16List(Cache_Length);
  final cacheTemplateA = Uint32List(Cache_Length);
  final cacheTemplateB = Uint32List(Cache_Length);
  final cacheTemplateC = Uint32List(Cache_Length);

  late final editState = EditState(this);

  IsometricGame game;
  Collider? selectedCollider;
  Collider? _aimTarget;
  int? aimNodeIndex;

  IsometricPlayer({
    required this.game,
    required super.x,
    required super.y,
    required super.z,
    required super.health,
    required super.team,
    bool autoTargetNearbyEnemies = false,
  }) : super(
    characterType: CharacterType.Human,
    attackRange: 100,
    weaponType: WeaponType.Unarmed,
    attackDamage: 1,
    attackDuration: 25,
  ){
    autoTarget = autoTargetNearbyEnemies;
    id = game.playerId++;
  }

  set debugging(bool value){
    if (_debugging == value) {
      return;
    }

    _debugging = value;
    writeDebugging();
  }

  int get playerMode => _playerMode;

  bool get debugging => _debugging;

  @override
  set runToDestinationEnabled(bool value){
    if (super.runToDestinationEnabled == value) {
      return;
    }

    super.runToDestinationEnabled = value;
    writeRunToDestinationEnabled();
  }

  @override
  set arrivedAtDestination(bool value){
    if (super.arrivedAtDestination == value) {
      return;
    }

    super.arrivedAtDestination = value;
    writePlayerArrivedAtDestination();
  }

  @override
  set maxHealth(double value){
    if (maxHealth == value) return;
    super.maxHealth = value;
    writePlayerHealth();
  }

  set playerMode(int value){
    _playerMode = value;
    writePlayerMode();
  }

  set health (double value) {
    if (health == value) return;
    super.health = value;
    writePlayerHealth();
  }

  Collider? get aimTarget => _aimTarget;

  int get aimTargetCategory => aimTargetAction;

  @override
  bool get isPlayer => true;

  set aimTargetCategory(int value){
    if (aimTargetAction == value) return;
    aimTargetAction = value;
    writePlayerAimTargetAction();
  }

  set aimTarget(Collider? value){
    if (value == _aimTarget) return;
    _aimTarget = value;
    onChangedAimTarget();
  }

  int get mouseIndex => game.scene.getIndexXYZ(mouseSceneX, mouseSceneY, mouseSceneZ);

  bool get aimTargetWithinInteractRadius => aimTarget != null
      ? getDistance(aimTarget!) < IsometricSettings.Interact_Radius
      : false;

  double get mouseSceneX => game.clampX((mouseX + mouseY) + z);

  double get mouseSceneY => game.clampY((mouseY - mouseX) + z);

  double get mouseSceneZ => game.clampZ(z);

  /// in radians
  double get mouseAngle => getAngleXY(
      mouseSceneX  + Character_Gun_Height,
      mouseSceneY + Character_Gun_Height,
  );

  Scene get scene => game.scene;

  double get mouseDistance => this.getDistanceXY(mouseSceneX, mouseSceneY);

  @override
  set complexion(int value) {
    if (complexion == value || value < 0 || value > 64) {
      return;
    }

    super.complexion = value;
    writePlayerComplexion();
  }

  @override
  set name(String value) {
    super.name = value;
    writePlayerName();
  }

  @override
  set helmType(int value) {
    super.helmType = value;
    writeHelmType();
  }

  @override
  set hairType(int value) {
    super.hairType = value;
    writeHairType();
  }

  @override
  set headType(int value) {
    super.headType = value;
    writeHeadType();
  }

  @override
  set shoeType(int value) {
    super.shoeType = value;
    writeShoeType();
  }

  @override
  set hairColor(int value) {
    super.hairColor = value;
    writeHairColor();
  }

  @override
  set armorType(int value) {
    super.armorType = value;
    writeArmorType();
  }

  // @override
  // set legsType(int value) {
  //   super.legsType = value;
  //   writeLegsType();
  // }

  @override
  set weaponType(int value) {
    super.weaponType = value;
    writeWeaponType();
  }

  // @override
  // set handTypeLeft(int value){
  //   super.handTypeLeft = value;
  //   writeHandTypeLeft();
  // }

  // @override
  // set handTypeRight(int value){
  //   super.handTypeRight = value;
  //   writeHandTypeRight();
  // }

  @override
  set gender(int value){
    super.gender = value;
    writeGender();
  }

  set mouseLeftDown(bool value){
    if (_mouseLeftDown != value) {
      _mouseLeftDown = value;
      if (value){
        onMouseLeftClicked();
      } else {
        onMouseLeftReleased();
      }
    } else {
      if (value){
        onMouseLeftHeld();
      }
    }
  }

  void writeErrorInvalidInventoryIndex(int index){
     writeGameError(GameError.Invalid_Inventory_Index);
  }

  // @override
  // void deactivate() {
  //   super.deactivate();
  //   writePlayerActive();
  // }

  void writePlayerPosition(){

    final diffX = -(positionCacheX - x.toInt()).toInt();
    final diffY = -(positionCacheY - y.toInt()).toInt();
    final diffZ = -(positionCacheZ - z.toInt()).toInt();

    if (diffX == 0 && diffY == 0 && diffZ == 0) return;

    if (diffX.abs() < 126 && diffY.abs() < 126 && diffZ.abs() < 126){
      writePlayerPositionDelta(diffX, diffY, diffZ);
    } else {
      writePlayerPositionAbsolute();
    }

    positionCacheX = x.toInt();
    positionCacheY = y.toInt();
    positionCacheZ = z.toInt();
  }

  void writePlayerHealth(){
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Health);
    writeUInt16(health.toInt());
    writeUInt16(maxHealth.toInt());
  }

  void writePlayerAlive(){
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Alive);
    writeBool(alive);
  }

  void writePlayerActive(){
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Active);
    writeBool(true);
    // writeBool(active);
  }

  void writePlayerAimAngle(){
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Aim_Angle);
    writeAngle(mouseAngle);
  }

  void writePlayerGame() {

    if (!initialized) {
      initialized = true;
      game.customInitPlayer(this);
      writePlayerPosition();
      writePlayerHealth();
      writePlayerAlive();
      writePlayerEvent(PlayerEvent.Spawned);
      writeDebugging();
      // writePlayerControls();
      initialize();
    }

    if (!sceneDownloaded) {
      downloadScene();
    }

    writePlayerPosition();
    writePlayerTargetPosition();
    writePlayerAimTargetPosition();
    writePlayerAimTargetAction();
    writePlayerDestination();
    writePlayerCharacterState();
    // writeSelectedCollider();
    writeCharacters();
    writeEditorGameObjectSelected();
    writeGameTime();
    writeAimTargetHealthPercentage();
    writeProjectiles();
  }

  void writeAimTargetHealthPercentage() {
    final aimTarget = this.aimTarget;
    if (aimTarget is Character && _cacheAimTargetHealthPercentage != aimTarget.healthPercentage) {
      _cacheAimTargetHealthPercentage = aimTarget.healthPercentage;
      writeByte(NetworkResponse.Player);
      writeByte(NetworkResponsePlayer.Aim_Target_Health);
      writePercentage(_cacheAimTargetHealthPercentage);
    }
  }

  void writeGameObjects(){
    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.GameObjects);
    final gameObjects = game.gameObjects;
    for (final gameObject in gameObjects) {
      writeGameObject(gameObject);
    }
  }

  void writeCharacters() {
    writeByte(NetworkResponse.Characters);

    const padding = 100.0;
    final characters = game.characters;
    final charactersLength = characters.length;
    final screenBottomPadded = screenBottom + padding;
    final screenTopPadded = screenTop - padding;
    final screenLeftPadded = screenLeft - padding;
    final screenRightPadded = screenRight + padding;

    final cachePositionX = this.cachePositionX;
    final cachePositionY = this.cachePositionY;
    final cachePositionZ = this.cachePositionZ;

    var cacheIndex = 0;

    for (var i = 0; i < charactersLength; i++) {

      final character = characters[i];

      final renderX = character.renderX;

      if (renderX < screenLeftPadded || renderX > screenRightPadded) {
        continue;
      }

      final renderY = character.renderY;

      if (renderY < screenTopPadded) {
        continue;
      }

      if (renderY > screenBottomPadded) {
        continue;
      }

      final characterX = character.x.toInt();
      final characterY = character.y.toInt();
      final characterZ = character.z.toInt();

      final diffX = -(cachePositionX[cacheIndex] - characterX);
      final diffY = -(cachePositionY[cacheIndex] - characterY);
      final diffZ = -(cachePositionZ[cacheIndex] - characterZ);

      final diffXChangeType = ChangeType.fromDiff(diffX);
      final diffYChangeType = ChangeType.fromDiff(diffY);
      final diffZChangeType = ChangeType.fromDiff(diffZ);

      final characterCompressedAilments = character.compressedAilments;
      final changedCharacterAilments = characterCompressedAilments != cacheAilments[cacheIndex];
      final changedCharacterTypeTeam = character.characterTypeAndTeam != cacheCharacterTypeAndTeam[cacheIndex];
      final changedCharacterState = character.characterState != cacheCharacterState[cacheIndex];
      final changedHealthPercByte = character.healthPercentageByte != cacheHealthPerc[cacheIndex];
      final changedDirection = character.direction != cacheDirection[cacheIndex];

      final animationFrameDiff = character.animationFrame - cacheAnimationFrame[cacheIndex];
      final changedFrame = animationFrameDiff != 0;
      final changedFrameByOne = animationFrameDiff == 1;
      final changedPosition =
          diffXChangeType != ChangeType.None ||
          diffYChangeType != ChangeType.None ||
          diffZChangeType != ChangeType.None ;

      final compressionA = writeBits(
          changedCharacterTypeTeam,
          changedCharacterState,
          changedHealthPercByte,
          changedCharacterAilments,
          changedDirection,
          changedFrame,
          changedFrameByOne,
          changedPosition,
      );

      writeTrue();
      writeByte(compressionA);

      if (changedCharacterTypeTeam) {
        writeByte(character.characterTypeAndTeam);
        cacheCharacterTypeAndTeam[cacheIndex] = character.characterTypeAndTeam;
      }

      if (changedCharacterState){
        writeByte(character.characterState);
        cacheCharacterState[cacheIndex] = character.characterState;
      }

      if (changedHealthPercByte) {
        writeByte(character.healthPercentageByte);
        cacheHealthPerc[cacheIndex] = character.healthPercentageByte;
      }

      if (changedCharacterAilments){
        writeByte(characterCompressedAilments);
        cacheAilments[cacheIndex] = characterCompressedAilments;
      }

      if (changedDirection) {
        writeByte(character.direction);
        cacheDirection[cacheIndex] = character.direction;
      }

      if (changedFrame) {
        if (!changedFrameByOne){
          writeByte(character.animationFrame);
        }
        cacheAnimationFrame[cacheIndex] = character.animationFrame;
      }

      if (changedPosition) {
        final compressionB =
          diffXChangeType << 2 |
          diffYChangeType << 4 |
          diffZChangeType << 6 ;
        writeByte(compressionB);

        if (diffXChangeType == ChangeType.One) {
          cachePositionX[cacheIndex]++;
        } else if (diffXChangeType == ChangeType.Delta) {
          writeInt8(diffX);
          cachePositionX[cacheIndex] = characterX;
        } else if (diffXChangeType == ChangeType.Absolute) {
          writeInt16(characterX);
          cachePositionX[cacheIndex] = characterX;
        }

        if (diffYChangeType == ChangeType.One) {
          cachePositionY[cacheIndex]++;
        } else if (diffYChangeType == ChangeType.Delta) {
          writeInt8(diffY);
          cachePositionY[cacheIndex] = characterY;
        } else if (diffYChangeType == ChangeType.Absolute) {
          writeInt16(characterY);
          cachePositionY[cacheIndex] = characterY;
        }

        if (diffZChangeType == ChangeType.One) {
          cachePositionZ[cacheIndex]++;
        } else if (diffZChangeType == ChangeType.Delta) {
          writeInt8(diffZ);
          cachePositionZ[cacheIndex] = characterZ;
        } else if (diffZChangeType == ChangeType.Absolute) {
          writeInt16(characterZ);
          cachePositionZ[cacheIndex] = characterZ;
        }
      }

      if (character.characterTypeTemplate) {
        writeCharacterTemplate(character, cacheIndex);
      }

      if (CharacterState.supportsAction.contains(character.characterState)){
        writePercentage(character.actionCompletionPercentage);
      }

      if (character is AmuletFiend){
        writeTrue();
        writeUInt16(character.level);
      } else {
        writeFalse();
      }

      cacheIndex++;
    }

    writeByte(CHARACTER_END);
  }

  void downloadScene(){
    writeGameRunning();
    writeGameTime();
    writeSecondsPerFrame();
    writePlayerTeam();
    writeEditEnabled();
    writeSceneDimensions();
    writeSceneVariations();
    writeSceneNodeTypes();
    writeSceneNodeOrientations();
    writeSceneMarks();
    writeNetworkResponseSceneKeys();
    writeNetworkResponseSceneChanged();
    writeWeather();
    writeGameObjects();
    writeFPS();
    writeAimNodeIndex();
    game.customDownloadScene(this);
    writePlayerEvent(PlayerEvent.Scene_Changed);
    sceneDownloaded = true;
  }

  void writeGameRunning() {
    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.Game_Running);
    writeBool(game.running);
  }

  void writePlayerTargetPosition(){
    final target = this.target;
    if (target == null) return;
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Target_Position);
    writeIsometricPosition(target);
  }

  void writePlayerDestination(){
    if (!runToDestinationEnabled || arrivedAtDestination) {
      return;
    }

    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Destination);
    writeDouble(runX);
    writeDouble(runY);
    writeDouble(runZ);
  }

  void writePlayerArrivedAtDestination(){
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Arrived_At_Destination);
    writeBool(arrivedAtDestination);
  }

  void writePlayerAimTargetPosition() {
    final aimTarget = this.aimTarget;
    if (aimTarget == null) return;
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Aim_Target_Position);
    writeIsometricPosition(aimTarget);
  }

  void writePlayerAimTargetAction() {
    if (aimTargetActionPrevious == aimTargetAction){
      return;
    }
    aimTargetActionPrevious = aimTargetAction;
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Aim_Target_Action);
    writeByte(aimTargetAction);
  }

  int getTargetAction(Position? value){

    if (value == null) {
      return TargetAction.Run;
    }

    if (value is GameObject) {
      if (value.interactable) {
        return TargetAction.Talk;
      }
      if (value.physical && value.hitable){
        return TargetAction.Attack;
      }
      return TargetAction.Run;
    }

    if (isEnemy(value)) {
      return TargetAction.Attack;
    }

    return TargetAction.Run;
  }

  bool onScreenPosition(Position position) =>
      onScreen(position.x, position.y);

  bool onScreen(double x, double y) =>
      screenLeft < x &&
      screenRight > x &&
      screenTop < y &&
      screenBottom > y;

  bool withinRadiusEventDispatchPos(Position position, {double minRadius = 800}) =>
      withinRadiusEventDispatch(
          position.x,
          position.y,
          minRadius: minRadius,
      );

  bool withinRadiusEventDispatch(
      double x,
      double y,
      {double minRadius = 800}
  ) =>
      (this.x - x).abs() < minRadius &&
      (this.y - y).abs() < minRadius;

  void writeProjectiles(){
    writeByte(NetworkResponse.Projectiles);
    final projectiles = game.projectiles;
    for (final projectile in projectiles){
      // if (!projectile.active) continue;
      writeTrue();
      writePosition(projectile);
      writeByte(projectile.type);
      writeAngle(projectile.velocityAngle);
    }
    writeFalse();
  }

  void writeGameEvent({
    required int type,
    required double x,
    required double y,
    required double z,
  }){
    writeByte(NetworkResponse.Game_Event);
    writeByte(type);
    writeDouble(x);
    writeDouble(y);
    writeDouble(z);
  }

  void writePlayerEventItemTypeConsumed(int itemType){
    writePlayerEvent(PlayerEvent.Item_Consumed);
    writeByte(itemType);
  }

  void writePlayerEventRecipeCrafted() =>
    writePlayerEvent(PlayerEvent.Recipe_Crafted);

  void writePlayerEventInventoryFull() =>
      writePlayerEvent(PlayerEvent.Inventory_Full);

  void writePlayerEventInvalidRequest() =>
      writePlayerEvent(PlayerEvent.Invalid_Request);

  void writePlayerEventItemAcquired(int itemType){
    writePlayerEvent(PlayerEvent.Item_Acquired);
    writeUInt16(itemType);
  }

  void writePlayerEvent(int value){
    writeByte(NetworkResponse.Player_Event);
    writeByte(value);
  }

  void writePlayerMoved(){
    writePlayerPosition();
    writePlayerEvent(PlayerEvent.Player_Moved);
  }

  void writeGameTime(){
    final gameTimeInMinutes = game.time.time ~/ Duration.secondsPerMinute;
    if (gameTimeInMinutes == this.gameTimeInMinutes) return;
    this.gameTimeInMinutes = gameTimeInMinutes;
    writeByte(NetworkResponse.Game_Time);
    writeUInt24(game.time.time);
  }

  void writeSecondsPerFrame(){
    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.Seconds_Per_Frame);
    writeUInt16(game.time.secondsPerFrame);
  }

  // void writeProjectile(Projectile projectile){
  //   if (!projectile.active) return;
  //   writePosition(projectile);
  //   writeByte(projectile.type);
  //   writeAngle(projectile.velocityAngle);
  // }

  void writeCharacterTemplate(Character character, int cacheIndex) {

    final compressedA = character.templateDataA;
    final compressedB = character.templateDataB;
    final compressedC = character.templateDataC;

    final writeA = cacheTemplateA[cacheIndex] != compressedA;
    final writeB = cacheTemplateB[cacheIndex] != compressedB;
    final writeC = cacheTemplateC[cacheIndex] != compressedC;

    final isPlayer = this == character;

    writeByte(
      writeBits(writeA, writeB, writeC, isPlayer, false, false, false, false)
    );

    if (writeA){
      cacheTemplateA[cacheIndex] = compressedA;
      writeByte(character.weaponType);
      writeByte(character.armorType);
      writeByte(character.helmType);
      writeByte(0);  // writeByte(character.legsType);
    }

    if (writeB){
      cacheTemplateB[cacheIndex] = compressedB;
      writeByte(character.complexion);
      writeByte(character.shoeType);
      writeByte(character.gender);
      writeByte(character.headType);
    }

    if (writeC){
      cacheTemplateC[cacheIndex] = compressedC;
      writeByte(0); // writeByte(character.handTypeLeft);
      writeByte(0);  // writeByte(character.handTypeRight);
      writeByte(character.hairType);
      writeByte(character.hairColor);
    }

    if (isPlayer) {
      writePercentage(character.magicPercentage);
    }
  }

  void writeWeather() {
    final environment = game.environment;
    writeByte(NetworkResponse.Environment);
    writeByte(NetworkResponseEnvironment.Weather);
    writeByte(environment.rainType);
    writeBool(environment.breezy);
    writeByte(environment.lightningType);
    writeByte(environment.windType);
    writeByte(environment.mystType);
    writeGameTimeEnabled();
  }

  void writePercentage(double value){
    if (value.isNaN) {
      writeByte(0);
      return;
    }
    if (value > 1.0) writeByte(255);
    writeByte((value * 255).toInt());
  }

  void writePosition(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeIsometricPosition(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  void writeVector3(Position value){
    writeDouble(value.x);
    writeDouble(value.y);
    writeDouble(value.z);
  }

  // void writeScene() {
  //   writeByte(NetworkResponse.Isometric);
  //   writeByte(NetworkResponseIsometric.Scene);
  //   var compiled = scene.compiled;
  //   if (compiled == null) {
  //     compiled = SceneWriter().compileScene(scene, gameObjects: false);
  //     scene.compiled = compiled;
  //   }
  //   writeBytes(compiled);
  // }

  void writeAngle(double radians){
    writeDouble(radians * radiansToDegrees);
  }

  void writeEditEnabled() {
    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.Edit_Enabled);
    writeBool(editEnabled);
  }

  void writeEditorGameObjectSelected() {
    final selectedGameObject = editState.selectedGameObject;
    if (selectedGameObject == null) return;
    writeByte(NetworkResponse.Editor);
    writeByte(NetworkResponseEditor.Editor_GameObject_Selected);
    writeUInt16(selectedGameObject.id);
    writeBool(selectedGameObject.hitable);
    writeBool(selectedGameObject.fixed);
    writeBool(false); // writeBool(selectedGameObject.collectable);
    writeBool(selectedGameObject.physical);
    // writeBool(selectedGameObject.persistable);
    writeBool(selectedGameObject.gravity);
    writeBool(selectedGameObject.interactable);
    writeBool(selectedGameObject.collidable);
  }

  void writeEnvironmentLightning(int value){
    writeByte(NetworkResponse.Environment);
    writeByte(NetworkResponseEnvironment.Lightning);
    writeByte(value);
  }

  void writeEnvironmentWind(int windType){
    writeByte(NetworkResponse.Environment);
    writeByte(NetworkResponseEnvironment.Wind);
    writeByte(windType);
  }

  void writeGameTimeEnabled(){
    writeByte(NetworkResponse.Environment);
    writeByte(NetworkResponseEnvironment.Time_Enabled);
    writeBool(game.time.enabled);
  }

  void writeEnvironmentRain(int rainType){
    writeByte(NetworkResponse.Environment);
    writeByte(NetworkResponseEnvironment.Rain);
    writeByte(rainType);
  }

  void writeEnvironmentBreeze(bool value){
    writeByte(NetworkResponse.Environment);
    writeByte(NetworkResponseEnvironment.Breeze);
    writeBool(value);
  }

  void writeEnvironmentLightningFlashing(){
    writeByte(NetworkResponse.Environment);
    writeByte(NetworkResponseEnvironment.Lightning_Flashing);
    writeBool(game.environment.lightningFlashing);
    writePercentage(game.environment.lightningFlash01);
  }

  void writeNode({
    required int index,
    required int type,
    required int shape,
    required int variation,
  }){
    assert (index >= 0);
    assert (index < scene.volume);
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Node);
    writeUInt24(index);
    writeByte(type);
    writeByte(shape);
    writeByte(variation);
  }

  void writeDouble(double value){
    writeInt16(value.toInt());
  }

  void writeGameObject(GameObject gameObject){
    writeByte(NetworkResponse.GameObject);
    writeUInt16(gameObject.id);
    writeByte(gameObject.itemType);
    writeUInt16(gameObject.subType);
    writeUInt16(gameObject.health.toInt());
    writeUInt16(gameObject.healthMax.toInt());
    writeIsometricPosition(gameObject);
  }

  void writeMap(Map<int, int> map){
    final entries = map.entries;
    writeUInt16(entries.length);
    for (final entry in entries) {
      writeUInt16(entry.key);
      writeUInt16(entry.value);
    }
  }

  void writeMapListInt(Map<int, List<int>> value){
    final entries = value.entries;
    writeUInt16(entries.length);
    for (final entry in entries) {
      writeUInt16(entry.key);
      writeUInt16(entry.value.length);
      writeUint16List(entry.value);
    }
  }

  void writePlayerId(){
    writeUInt8(NetworkResponse.Player);
    writeUInt8(NetworkResponsePlayer.Id);
    writeUInt24(id);
  }

  void writeGameEventGameObjectDestroyed(GameObject gameObject){
    writeGameEvent(
      type: GameEvent.Game_Object_Destroyed,
      x: gameObject.x,
      y: gameObject.y,
      z: gameObject.z,
    );
    writeByte(gameObject.itemType);
    writeByte(gameObject.subType);
  }

  void writePlayerTeam(){
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Team);
    writeByte(team);
  }

  void writeGameError(GameError value){
    writeByte(NetworkResponse.Game_Error);
    writeByte(value.index);
  }

  void onMouseLeftReleased(){

  }

  void onMouseLeftClicked(){

  }

  void onMouseLeftHeld(){

  }

  void setPathToMouse() => pathTargetIndex = mouseIndex;

  void setDestinationToMouse() {
    setRunDestination(mouseSceneX, mouseSceneY, mouseSceneZ);
    runToDestinationEnabled = true;
    pathFindingEnabled = false;
    target = null;
  }

  void writeSelectedCollider() {
    final selectedCollider = this.selectedCollider;

    if (selectedCollider == null) {
      if (!selectedColliderDirty) return;
      selectedColliderDirty = false;
      writeByte(NetworkResponse.Isometric);
      writeByte(NetworkResponseIsometric.Selected_Collider);
      writeBool(false);
      return;
    }
    selectedColliderDirty = true;

    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.Selected_Collider);
    writeBool(true);
    writeBool(false); // selectedCollider is AmuletPlayer
    // if (selectedCollider is AmuletPlayer){
    //   writeBool(true);
    //   // writeAmuletItemSlot(selectedCollider.equippedWeapon);
    //   // writeAmuletItemSlot(selectedCollider.equippedWeapon); // TODO
    //   // writeAmuletItemSlot(selectedCollider.activeAmuletItemSlot);
    // } else {
    //   writeBool(false);
    // }

    if (selectedCollider is GameObject) {
      final gameObject = selectedCollider;
      writeByte(IsometricType.GameObject);
      writeString(gameObject.runtimeType.toString());
      writeUInt16(gameObject.team);
      writeUInt16(gameObject.radius.toInt());
      writeUInt16(gameObject.health.toInt());
      writeUInt16(gameObject.healthMax.toInt());
      writeIsometricPosition(gameObject);
      writeByte(gameObject.itemType);
      writeByte(gameObject.subType);
      return;
    }

    if (selectedCollider is Character) {
      final character = selectedCollider;
      writeByte(IsometricType.Character);
      writeString(character.runtimeType.toString());
      writeByte(character.action);
      writeByte(character.goal);
      writeUInt16(character.team);
      writeUInt16(character.radius.toInt());
      writeUInt16(selectedCollider.health.toInt());
      writeUInt16(selectedCollider.maxHealth.toInt());
      writeIsometricPosition(character);
      writeInt16(character.runX.toInt());
      writeInt16(character.runY.toInt());
      writeCharacterPath(character);

      writeByte(character.characterType);
      writeByte(character.characterState);
      writeByte(character.complexion);
      writeClampUInt16(character.actionDuration);
      writeClampUInt16(character.frame.toInt());
      writeUInt16(character.weaponType);
      writeUInt16(character.attackDamage.toInt());
      writeUInt16(character.attackRange.toInt());
      writeByte(0); // TODO
      writeUInt16(0); // TODO
      writeBool(character.autoTarget);
      writeBool(character.pathFindingEnabled);
      writeBool(character.runToDestinationEnabled);
      writeBool(character.arrivedAtDestination);

      final selectedCharacterTarget = character.target;
      if (selectedCharacterTarget == null){
        writeBool(false);
      } else {
        writeBool(true);
        writeString(selectedCharacterTarget.runtimeType.toString());
        writeIsometricPosition(selectedCharacterTarget);
      }
    }
  }

  void writeCharacterPath(Character character){
    writeInt16(character.pathCurrent);
    writeInt16(character.pathStart);
    writeInt16(character.pathTargetIndex);
    for (var j = 0; j < character.pathStart; j++){
      writeUInt16(character.path[j]);
    }
  }

  void selectNearestColliderToMouse({double maxRadius = 75}) =>
      selectedCollider = getNearestColliderToMouse(maxRadius: maxRadius);

  Collider? getNearestColliderToMouse({
    required double maxRadius
  }) => game.getNearestCollider(
      x: mouseSceneX,
      y: mouseSceneY,
      z: z,
      maxRadius: maxRadius,
    );

  void debugCommand() {
    final selectedCollider = this.selectedCollider;
    if (selectedCollider is! Character) {
      return;
    }

    final nearestMouseCollider = getNearestColliderToMouse(maxRadius: 75);
    if (nearestMouseCollider == selectedCollider) {
      return;
    }

    if (nearestMouseCollider != null) {
      selectedCollider.target = nearestMouseCollider;
      return;
    }

    selectedCollider.target = null;

    if (selectedCollider.pathFindingEnabled) {
      selectedCollider.pathTargetIndex = mouseIndex;
      return;
    }

    if (selectedCollider.runToDestinationEnabled) {
      selectedCollider.setRunDestination(
          mouseSceneX,
          mouseSceneY,
          mouseSceneZ,
      );
      return;
    }
  }

  void lookAtMouse(){
    if (deadOrBusy) return;
    angle = mouseAngle + pi;
  }

  void onChangedAimTarget(){
     aimTargetCategory = getTargetAction(aimTarget);
     writePlayerAimTarget();
  }

  void writePlayerAimTarget(){
    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.Player_Aim_Target);

    final aimTarget = this.aimTarget;
    writeBool(aimTarget != null);
    if (aimTarget == null) {
      return;
    }
    writeString(aimTarget.name);
  }

  void performPrimaryAction() {
    if (deadOrBusy) {
      return;
    }

    if (aimTarget == null) {
      setDestinationToMouse();
      runToDestinationEnabled = true;
      pathFindingEnabled = false;
      target = null;
      return;
    }

    setTargetToAimTarget();
  }

  void setTargetToAimTarget() {
    target = aimTarget;
    runToDestinationEnabled = true;
    pathFindingEnabled = false;
  }

  void writeRunToDestinationEnabled() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Run_To_Destination_Enabled);
    writeBool(runToDestinationEnabled);
  }

  void writeDebugging() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Debugging);
    writeBool(debugging);
  }

  void toggleDebugging() {
    debugging = !debugging;
  }

  // void writePlayerControls(){
  //   writeByte(NetworkResponse.Isometric);
  //   writeByte(NetworkResponseIsometric.Player_Controls);
  //   writeBool(controlsCanTargetEnemies);
  //   writeBool(false); // TODO delete on client
  // }

  // void toggleControlsCanTargetEnemies() {
  //   controlsCanTargetEnemies = !controlsCanTargetEnemies;
  //   writePlayerControls();
  // }

  @override
  void update() {
    super.update();

    framesSinceClientRequest++;

    if (dead) return;

    game.updatePlayerAimTarget(this);
    updateAimNodeIndex();
  }

  double getMouseDistance() => this.getDistanceXYZ(mouseSceneX, mouseSceneY, mouseSceneZ);

  double getMouseAngle() => getAngleXY(mouseSceneX, mouseSceneY);

  void reportException(Object exception) {
    // TODO: implement writeError
  }

  void writeHeadType() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.HeadType);
    writeByte(headType);
  }

  void writeHelmType() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.HelmType);
    writeByte(helmType);
  }

  void writeArmorType() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.ArmorType);
    writeByte(armorType);
  }

  void writeWeaponType() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.WeaponType);
    writeByte(weaponType);
  }

  void writePlayerComplexion() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Complexion);
    writeByte(complexion);
  }

  void writePlayerName() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Name);
    writeString(name);
  }

  void writePlayerMode() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Player_Mode);
    writeByte(_playerMode);
  }

  void writeHairType() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.HairType);
    writeByte(hairType);
  }

  void writeHairColor() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.HairColor);
    writeByte(hairColor);
  }

  writeClampUInt16(int value) => writeUInt16(value.clamp(0, 65535));

  void writeShoeType() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.ShoeType);
    writeByte(shoeType);
  }

  void writeGender() {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Gender);
    writeByte(gender);
  }

  void toggleGender() =>
    gender = gender == Gender.male ? Gender.female : Gender.male;

  void writePlayerPositionDelta(int diffX, int diffY, int diffZ) {
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Position_Delta);
    writeInt8(diffX);
    writeInt8(diffY);
    writeInt8(diffZ);
  }

  void writePlayerPositionAbsolute() {
    positionCacheX = x.toInt();
    positionCacheY = y.toInt();
    positionCacheZ = z.toInt();
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Position_Absolute);
    writeInt16(x.toInt());
    writeInt16(y.toInt());
    writeInt16(z.toInt());
  }

  void writeSceneVariations(){
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Variations);
    compressAndWrite(game.scene.variations);
  }

  void writeSceneNodeTypes(){
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Node_Types);
    compressAndWrite(game.scene.nodeTypes);
  }

  void writeSceneNodeOrientations(){
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Node_Orientations);
    compressAndWrite(game.scene.nodeOrientations);
  }

  void writeSceneMarks() {
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Marks);
    final marks = scene.marks;
    writeUInt16(marks.length);
    for (final mark in marks){
      writeUInt32(mark);
    }
  }

  void writeNetworkResponseSceneKeys(){
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Keys);
    final keys = scene.keys;
    final length = keys.length;
    writeUInt16(length);
    final entries = keys.entries;
    for (final entry in entries){
      writeString(entry.key);
      writeUInt16(entry.value);
    }
  }

  void writeNetworkResponseSceneChanged(){
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Changed);
  }

  void compressAndWrite(List<int> bytes) {
    final compressed = encoder.encode(bytes);
    writeUInt16(compressed.length);
    writeBytes(compressed);
  }

  void writeSceneKeys() {
    final keys = scene.keys;
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Keys);
    writeUInt16(keys.length);

    final entries = keys.entries;
    for (final entry in entries) {
       writeString(entry.key);
       writeUInt16(entry.value);
    }
  }

  void writePlayerCharacterState() {
    final characterState = this.characterState;

    if (_previousCharacterState == characterState){
      return;
    }
    _previousCharacterState = characterState;
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Character_State);
    writeByte(characterState);
  }

  void initialize() {

  }

  void writeZoom(double value){
    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.Zoom);
    writeDouble(value * 10);
  }

  void performForceAttack(){
    if (deadOrBusy){
      return;
    }
    lookAtMouse();
    game.characterGoalForceAttack(this);
  }

  void writeFPS() {
    writeByte(NetworkResponse.FPS);
    writeUInt16(Frames_Per_Second);
  }

  void clearCache() {
    cacheTemplateA.fillRange(0, cacheTemplateA.length, 0);
    cacheTemplateB.fillRange(0, cacheTemplateB.length, 0);
    cacheTemplateC.fillRange(0, cacheTemplateC.length, 0);
    cachePositionX.fillRange(0, cachePositionX.length, 0);
    cachePositionY.fillRange(0, cachePositionY.length, 0);
    cachePositionZ.fillRange(0, cachePositionZ.length, 0);
    cacheCharacterTypeAndTeam.fillRange(0, cacheCharacterTypeAndTeam.length, 0);
    cacheCharacterState.fillRange(0, cacheCharacterState.length, 0);
    cacheHealthPerc.fillRange(0, cacheHealthPerc.length, 0);
    cacheDirection.fillRange(0, cacheDirection.length, 0);
    cacheAnimationFrame.fillRange(0, cacheAnimationFrame.length, 0);
    cacheAilments.fillRange(0, cacheAilments.length, 0);
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Cache_Cleared);
  }

  void setControlsEnabled(bool value){
    controlsEnabled = value;
    writeByte(NetworkResponse.Player);
    writeByte(NetworkResponsePlayer.Controls_Enabled);
    writeBool(value);
  }

  void writeSceneDimensions() {
    writeByte(NetworkResponse.Scene);
    writeByte(NetworkResponseScene.Dimensions);
    writeUInt16(scene.height);
    writeUInt16(scene.rows);
    writeUInt16(scene.columns);
  }

  void updateAimNodeIndex(){

    if (aimTarget != null) {
      setAimNodeIndex(null);
      return;
    }

    var z = scene.height - 1;
    final mouseWorldX = this.mouseX;
    final mouseWorldY = this.mouseY;

    final rows = scene.rows;
    final columns = scene.columns;
    final height = scene.height;

    while (z >= 0) {
      final row = convertRenderToRow(mouseWorldX, mouseWorldY, z * Node_Height);
      final column = convertRenderToColumn(mouseWorldX, mouseWorldY, z * Node_Height);

      if (
        row < 0 ||
        column < 0 ||
        row >= rows ||
        column >= columns ||
        z >= height
      ) break;

      final index = scene.getIndex(z, row, column);
      if (canInteractWithNodeAtIndex(index)) {
         setAimNodeIndex(index);
         return;
      }
      z--;
    }
    setAimNodeIndex(null);
  }

  bool canInteractWithNodeAtIndex(int index) => false;

  void setAimNodeIndex(int? value){
    if (aimNodeIndex == value) return;
    aimNodeIndex = value;
    writeAimNodeIndex();
  }

  void writeAimNodeIndex(){
    writeByte(NetworkResponse.Isometric);
    writeByte(NetworkResponseIsometric.Aim_Node_Index);
    final aimNodeIndex = this.aimNodeIndex;
    if (aimNodeIndex == null){
      writeFalse();
      return;
    }
    writeTrue();
    writeUInt16(aimNodeIndex);
    writeByte(scene.nodeTypes[aimNodeIndex]);
  }

  @override
  set targetNodeIndex(int? value) {
    super.targetNodeIndex = value;
    if (value == null) {
      return;
    }
    setRunDestinationToIndex(value);
  }


  void setRunDestinationToIndex(int index) =>
      setRunDestination(
        scene.getIndexX(index),
        scene.getIndexY(index),
        scene.getIndexZ(index),
      );

  void writeGameObjectDeleted(GameObject gameObject){
    writeUInt8(NetworkResponse.Scene);
    writeUInt8(NetworkResponseScene.GameObject_Deleted);
    writeUInt16(gameObject.id);
  }

  void editorDeselectGameObject() {
    if (editState.selectedGameObject == null) return;
    editState.selectedGameObject = null;
    writePlayerEvent(PlayerEvent.GameObject_Deselected);
  }

  bool canAimAt(GameObject gameObject) =>
      gameObject.interactable || gameObject.hitable;
}
