
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/isometric/ui/constants/editor_grid_type_columns.dart';

Widget buildColumnSelectNodeType() =>
  Container(
    height: Engine.screen.height - 70,
    child: SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: editorGridTypesColumn1.map(EditorUI.buildButtonSelectNodeType).toList(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: editorGridTypesColumn2.map(EditorUI.buildButtonSelectNodeType).toList(),
          ),
        ],
      ),
    ),
  );

Widget buildColumnSelectObjectType(){
  return Column();
}