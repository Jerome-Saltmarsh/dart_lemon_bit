
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/src.dart';
import 'package:bleed_server/src/game/player.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_ai.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_power.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';
import 'package:bleed_server/src/games/isometric/isometric_position.dart';
import 'package:bleed_server/src/utilities/change_notifier.dart';

import 'mixins/i_capture_the_flag_team.dart';


class CaptureTheFlagPlayer extends IsometricPlayer with ICaptureTheFlagTeam {

  IsometricCharacter? selectedCharacter;
  IsometricPosition? activatedPowerTarget;

  var ignoreMouseLeftClick = false;
  var activatedPowerX = 0.0;
  var activatedPowerY = 0.0;

  @override
  final CaptureTheFlagGame game;
  final CaptureTheFlagPower power1;
  final CaptureTheFlagPower power2;

  /// The power the places has selected but must still caste
  late final powerActivated = ChangeNotifier<CaptureTheFlagPower?>(null, onActivatedPowerChanged);
  CaptureTheFlagPower? powerPerforming;

  late final flagStatus = ChangeNotifier(
      CaptureTheFlagPlayerStatus.No_Flag,
      onChangedFlagStatus,
  );

  CaptureTheFlagPlayer({
    required this.game,
    required this.power1,
    required this.power2,
  }) : super(game: game) {
    writeScore();
    weaponDamage = 1;
    weaponType = ItemType.Empty;
  }

  bool get shouldUpdatePathToMouse => game.scene.inboundsXYZ(mouseGridX, mouseGridY, 25);

  bool get canDeselectActivatedPower => powerActivated.value != null;

  @override
  bool get canSetCharacterStateHurt => !performing && !weaponStateBusy;

  bool get canUpdatePowerPosition => powerActivated.value != null && !performing;

  bool get canUpdatePowerTarget {
    final power = powerActivated.value;
    if (power == null) return false;
    if (performing) return false;
    return power.isTargeted;
  }

  bool get canPerformActivatedPower {
    final power = powerActivated.value;
    if (power == null)
      return false;
    if (power.isTargeted && activatedPowerTarget == null)
      return false;
    return true;
  }

  @override
  void customUpdate() {
    if (shouldUpdatePathToMouse){
      updatePathToMouse();
    }

    updatePowers();
  }

  void updatePowers() {
    power1.update();
    power2.update();
  }

  void updatePathToMouse() =>
      setPathToNodeIndex(game.scene, game.scene.getNodeIndexXYZ(mouseGridX, mouseGridY, 25));

  void onChangedFlagStatus(int value) => writePlayerFlagStatus(value);

  @override
  void writePlayerGame() {
    super.writePlayerGame();
    writeFlagPositions(); // todo optimize
    writeBasePositions(); // todo optimize
    writeSelectedCharacter(); // todo optimize
    writeActivatedPowerPosition(); // todo optimize
    writeActivatedPowerTarget(); // todo optimize
    writePower1(); // todo optimize
    writePower2(); // todo optimize
  }

  void writeActivatedPowerPosition() {
    if (powerActivated.value == null) return;
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Activated_Power_Position);
    writeUInt24(activatedPowerX.toInt());
    writeUInt24(activatedPowerY.toInt());
  }

  void writeActivatedPowerTarget() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Activated_Power_Target);
    if (powerActivated.value == null) {
      writeBool(false);
      return;
    }
    final activatedPowerTarget = this.activatedPowerTarget;
    if (activatedPowerTarget == null) {
      writeBool(false);
      return;
    }
    writeBool(true);
    writeIsometricPosition(activatedPowerTarget);
  }

  void writeFlagPositions() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Flag_Positions);
    writeIsometricPosition(game.flagRed);
    writeIsometricPosition(game.flagBlue);
  }

  void writeBasePositions() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Base_Positions);
    writeIsometricPosition(game.baseRed);
    writeIsometricPosition(game.baseBlue);
  }

  void writePlayerFlagStatus(int flagStatus) {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Player_Flag_Status);
    writeByte(flagStatus);
  }

  void writeScore() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Score);
    writeUInt16(game.scoreRed.value);
    writeUInt16(game.scoreBlue.value);
  }

  void writeFlagStatus() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Flag_Status);
    writeByte(game.flagRed.status);
    writeByte(game.flagBlue.status);
  }

  void setFlagStatusNoFlag(){
     flagStatus.value = CaptureTheFlagPlayerStatus.No_Flag;
  }

  void setFlagStatusHoldingEnemyFlag(){
    flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Enemy_Flag;
  }

  void writeSelectClass(bool value){
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Select_Class);
    writeBool(value);
  }

  void writeCaptureTheFlagGameStatus(CaptureTheFlagGameStatus value){
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Game_Status);
    writeByte(value.index);
  }

  void writeNextGameCountDown(int value) {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Next_Game_Count_Down);
    writeUInt16(value);
  }

  void writeAITarget(){
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.AI_Targets);
    final characters = game.characters;
    for (final character in characters){
       if (!character.active) continue;
       final characterTarget = character.target;
       if (characterTarget == null) continue;
       writeBool(true);
       writeIsometricPosition(character);
       writeIsometricPosition(characterTarget);
    }
    writeBool(false);
  }

  void writeAIList(){
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.AI_List);
    final characters = game.characters;
    for (final character in characters){
       if (!character.active) continue;
       if (character is! CaptureTheFlagAI) continue;
       final characterTarget = character.target;
       if (characterTarget == null) continue;
       writeBool(true);
       writeUInt24(character.id);
    }
    writeBool(false);
  }

  void writeAIPath(){
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.AI_Paths);
    final characters = game.characters;
    writeUInt16(characters.length);
    for (var i = 0; i < characters.length; i++){
      writeCharacterPath(characters[i]);
    }
  }

  void writeCharacterPath(IsometricCharacter character){
    writeUInt16(character.pathIndex);
    writeUInt16(character.pathEnd);
    for (var j = 0; j < character.pathEnd; j++){
      writeUInt16(character.path[j]);
    }
  }

  void writeSelectedCharacter() {
    final selectedCharacter = this.selectedCharacter;
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Selected_Character);

    if (selectedCharacter == null) {
      writeBool(false);
      return;
    }
    writeBool(true);
    writeString(selectedCharacter.runtimeType.toString());
    writeIsometricPosition(selectedCharacter);
    writeCharacterPath(selectedCharacter);

    if (selectedCharacter is CaptureTheFlagAI){
      writeBool(true);
      writeByte(selectedCharacter.decision.index);
      writeByte(selectedCharacter.role.index);
    } else {
      writeBool(false);
    }

    final selectedCharacterTarget = selectedCharacter.target;
    if (selectedCharacterTarget == null){
      writeBool(false);
    } else {
      writeBool(true);
      writeString(selectedCharacterTarget.runtimeType.toString());
      writeIsometricPosition(selectedCharacterTarget);
    }
  }

  void selectAINearestToMouse() {
     selectedCharacter = game.getNearestCharacter(mouseGridX, mouseGridY, z, maxRadius: 75);
  }

  void activatePower1() => activatePower(power1);

  void activatePower2() => activatePower(power2);

  void activatePower(CaptureTheFlagPower value) {
    if (!value.ready) {
      writeGameError(GameError.Power_Not_Ready);
      return;
    }
    powerActivated.value = value;
  }


  void onActivatedPowerChanged(CaptureTheFlagPower? value){
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Activated_Power);
    if (value == null) {
      writeBool(false);
      return;
    }
    writeBool(true);
    writeByte(value.type.index);
    writeUInt16(value.range.toInt());
  }

  void writePower1() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Power_1);
    writePower(power1);
  }

  void writePower2() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Power_2);
    writePower(power2);
  }

  void writePower(CaptureTheFlagPower power) {
    writeByte(power.type.index);
    writeUInt16(power.cooldown);
    writeUInt16(power.cooldownRemaining);
    writeBool(powerActivated.value == power);
  }

  void performActivatedPower() {
    assert (canPerformActivatedPower);
    powerPerforming = powerActivated.value;
    deselectActivatedPower();
    setCharacterStatePerforming(duration: 30);
  }

  void deselectActivatedPower(){
     powerActivated.value = null;
  }

  @override
  void onWeaponTypeChanged() {
    weaponRange = game.getWeaponTypeRange(weaponType);
  }


  bool get shouldUsePowerPerforming {
    if (!performing)
      return false;
    if (stateDuration != 20)
      return false;
    if (powerPerforming == null)
      return false;
    return true;

  }
}