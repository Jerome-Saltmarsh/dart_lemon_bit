
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/enums/edit_tool.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/edit_tool.dart';

import '../../../flutterkit.dart';

Widget buildTabEditTool(){
  return watch(editTool, (EditTool activeEditTool){
      return Column(
        children: [
          Row(
            children: EditTool.values.map((tool){
               return container(
                 child: tool.name,
                 action: () => editTool.value = tool,
                 color: tool == activeEditTool ? greyDark : grey,
               );
            }).toList(),
          ),
        ],
      );
  });
}
