
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/editor/render/buildEnvironmentType.dart';
import 'package:flutter/material.dart';

Widget buildEnvironmentObjects() {
  return Column(
      children:
      EnvironmentObjectType.values.map(buildEnvironmentType).toList());
}