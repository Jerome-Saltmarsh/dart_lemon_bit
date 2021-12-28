
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:bleed_client/ui/compose/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../editor.dart';

Widget buildEnvironmentType(ObjectType type) {
  return WatchBuilder(editor.objectType, (ObjectType selected){
    return button(parseEnvironmentObjectTypeToString(type), () {
      editor.objectType.value = type;
    },
        fillColor: type == selected ? colours.purple : colours.transparent,
        width: 200,
        alignment: Alignment.centerLeft
    );
  });
}

Widget buildEnvironmentObject(EnvironmentObject type) {
  return button(parseEnvironmentObjectTypeToString(type.type), () {
    editState.selectedObject = type;
  });
}