
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/constants/complexions.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';

Widget buildColumnSelectComplexion(){
  return Column(
    children: complexions.map((complexion) =>
      container(
         color: complexion,
        action: () => complexionSelected = complexion,
      )
    ).toList(),
  );
}