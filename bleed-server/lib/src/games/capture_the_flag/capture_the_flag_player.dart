
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_game_status.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_player_status.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player_ai.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';
import 'package:bleed_server/src/utilities/change_notifier.dart';

class CaptureTheFlagPlayer extends IsometricPlayer {

  @override
  final CaptureTheFlagGame game;

  IsometricCharacter? selectedCharacter;

  late final debugMode = ChangeNotifier(false, onChangedDebugMode);

  late final flagStatus = ChangeNotifier(
      CaptureTheFlagPlayerStatus.No_Flag,
      onChangedFlagStatus,
  );

  CaptureTheFlagPlayer({required this.game}) : super(game: game) {
    writeScore();
    writeDebugMode();
    damage = 1;
    weaponType = ItemType.Empty;
  }

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  @override
  void customUpdate() {
    if (game.scene.inboundsXYZ(mouseGridX, mouseGridY, 25)){
      setPathToNodeIndex(game.scene, game.scene.getNodeIndexXYZ(mouseGridX, mouseGridY, 25));
    }
  }

  void onChangedFlagStatus(int value){
    writePlayerFlagStatus(value);
  }

  void onChangedDebugMode(bool value){
    writeDebugMode();
  }

  void writeDebugMode() {
    writeByte(ServerResponse.Capture_The_Flag);
    writeByte(CaptureTheFlagResponse.Debug_Mode);
    writeBool(debugMode.value);
  }

  @override
  void writePlayerGame() {
    super.writePlayerGame();
    writeFlagPositions(); // todo optimize
    writeBasePositions(); // todo optimize
    writeSelectedCharacter();

    if (debugMode.value) {
      writeAIPath();
      writeAITarget();
    }
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
       if (character is! CaptureTheFlagPlayerAI) continue;
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
    writeIsometricPosition(selectedCharacter);
    writeCharacterPath(selectedCharacter);

    final selectedCharacterTarget = selectedCharacter.target;
    if (selectedCharacterTarget == null){
      writeBool(false);
    } else {
      writeBool(true);
      writeString(selectedCharacterTarget.runtimeType.toString());
      writeIsometricPosition(selectedCharacterTarget);
    }
  }

  void toggleDebugMode() {
    debugMode.value = !debugMode.value;
  }

  void selectAINearestToMouse(){
     selectedCharacter = getNearestCharacter(mouseGridX, mouseGridY, z);
  }

  IsometricCharacter? getNearestCharacter(double x, double y, double z){
    IsometricCharacter? nearestCharacter;
    var nearestEnemyDistanceSquared = 100000000.0;
    final characters = game.characters;
    for (final character in characters){
      final distanceSquared = character.getDistanceXYZSquared(x, y, z);
      if (distanceSquared > nearestEnemyDistanceSquared) continue;
      nearestEnemyDistanceSquared = distanceSquared;
      nearestCharacter = character;
    }
    return nearestCharacter;
  }
}