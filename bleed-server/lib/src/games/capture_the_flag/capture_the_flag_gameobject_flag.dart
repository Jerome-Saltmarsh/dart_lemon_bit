
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_flag_status.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_team.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';

class CaptureTheFlagGameObjectFlag extends IsometricGameObject {

  var status = 0;
  var respawnDuration = 0;
  IsometricCollider? heldBy;


  CaptureTheFlagGameObjectFlag({required super.x, required super.y, required super.z, required super.type, required super.id}) {
    recyclable = false;
    fixed = false;
    physical = false;
    collidable = true;
    persistable = false;
  }

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  bool get statusAtBase => status == CaptureTheFlagFlagStatus.At_Base;
  bool get statusCarriedByEnemy => status == CaptureTheFlagFlagStatus.Carried_By_Enemy;
  bool get statusCarriedByAlly => status == CaptureTheFlagFlagStatus.Carried_By_Ally;
  bool get statusDropped => status == CaptureTheFlagFlagStatus.Dropped;
  bool get statusRespawning => status == CaptureTheFlagFlagStatus.Respawning;
}