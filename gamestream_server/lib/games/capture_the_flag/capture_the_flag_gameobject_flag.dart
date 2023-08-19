
import 'package:gamestream_server/common.dart';

import 'mixins/i_capture_the_flag_team.dart';
import 'package:gamestream_server/isometric/src.dart';

class CaptureTheFlagGameObjectFlag extends GameObject with ICaptureTheFlagTeam {

  var status = 0;
  var respawnDuration = 0;
  Collider? heldBy;


  CaptureTheFlagGameObjectFlag({
    required super.x,
    required super.y,
    required super.z,
    required super.id,
    required super.subType,
    required super.team,
  }) :super(type: ItemType.Object) {
    recyclable = false;
    fixed = false;
    physical = false;
    collidable = true;
    persistable = false;
    gravity = false;
  }

  bool get statusAtBase => status == CaptureTheFlagFlagStatus.At_Base;
  bool get statusCarriedByEnemy => status == CaptureTheFlagFlagStatus.Carried_By_Enemy;
  bool get statusCarriedByAlly => status == CaptureTheFlagFlagStatus.Carried_By_Ally;
  bool get statusDropped => status == CaptureTheFlagFlagStatus.Dropped;
  bool get statusRespawning => status == CaptureTheFlagFlagStatus.Respawning;

  void setStatusDropped(){
    status = CaptureTheFlagFlagStatus.Dropped;
  }
}