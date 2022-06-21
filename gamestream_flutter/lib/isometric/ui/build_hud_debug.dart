
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:lemon_engine/engine.dart';

Widget buildHudDebug(){
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     mainAxisAlignment: MainAxisAlignment.start,
     children: [
       _buildContainerMouseInfo(),
       _buildContainerPlayerInfo(),
     ],
   );
}


Widget _buildContainerMouseInfo(){
   return Refresh(() {
      return Container(
         height: 50,
         alignment: Alignment.centerLeft,
         color: Colors.grey,
         child: text("mouseGridX: ${mouseGridX.toInt()}, mouseGridY: ${mouseGridY.toInt()}, mousePlayerAngle: ${mousePlayerAngle.toStringAsFixed(1)}, mouseWorldX: ${mouseWorldX.toInt()}, mouseWorldY: ${mouseWorldY.toInt()}"),
      );
   });
}

Widget _buildContainerPlayerInfo(){
   return Refresh((){
      return Container(
          height: 50,
          alignment: Alignment.centerLeft,
          color: Colors.grey,
          child: text("Player zIndex: ${player.indexZ}, row: ${player.indexRow}, column: ${player.indexColumn}, x: ${player.x}, y: ${player.y}, z: ${player.z}, renderX: ${player.renderX}, renderY: ${player.renderY}, angle: ${player.angle}, mouseAngle: ${player.mouseAngle}",));
   });
}