
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';

Widget buildControlEditZ(){
   return watch(gridTotalZWatch, (int totalZ){
     return watch(edit.z, (z) {
       const width = 50.0;
         final children = <Widget>[
           container(child: "Z", width: width),
         ];

         for (var i = 0; i < totalZ; i++){
            children.add(
               container(
                  child: text(i),
                  action: () => edit.z.value = i,
                  color: z == i ? greyDark : grey,
                  width: width,
               )
            );
         }

         return Column(
           children: children,
         );
     });
   });
}