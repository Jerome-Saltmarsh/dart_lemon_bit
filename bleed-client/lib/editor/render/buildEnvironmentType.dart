
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/editor/enums/EditTool.dart';
import 'package:bleed_client/editor/state/editTool.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/material.dart';

Widget buildEnvironmentType(EnvironmentObjectType type) {
  return button(parseEnvironmentObjectTypeToString(type), () {
    tool = EditTool.EnvironmentObject;
    editState.environmentObjectType = type;
  });
}