import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_watch/watch.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Widget buildHudPlayMode() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildColumnBlendMode(),
      ColorPicker(pickerColor: Color(renderColor), onColorChanged: (value){
          renderColor = value.value;
      })
    ],
  );
}


Widget buildColumnBlendMode() {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(child: text("Blend Mode")),
        Container(
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children: BlendMode.values.map((blendMode) {
                return watch(blendModeWatch, (activeBlendMode){
                   return onPressed(
                     callback: () => blendModeWatch.value = blendMode,
                     child: Container(
                       width: 200,
                       height: 50,
                       color: blendMode == activeBlendMode ? Colors.green : Colors.grey,
                       child: text(blendMode.name),
                       alignment: Alignment.centerLeft,
                       padding: EdgeInsets.only(left: 6),
                     ),
                   );
                });
              }).toList(),
            ),
          ),
        ),
      ],
    );
}

final blendModeWatch = Watch(renderBlendMode, onChanged: (value) {
  renderBlendMode = value;
});

