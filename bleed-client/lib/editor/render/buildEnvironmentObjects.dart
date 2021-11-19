
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/editor/render/buildEnvironmentType.dart';
import 'package:flutter/material.dart';

Widget buildEnvironmentObjects() {
  return Column(
      children:
      ObjectType.values.map(buildEnvironmentType).toList());
}