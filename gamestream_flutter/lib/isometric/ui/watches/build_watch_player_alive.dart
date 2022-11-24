

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:golden_ratio/constants.dart';

import '../widgets/build_container.dart';

Widget buildContainerRespawn(){
  const width = 200;
  return Positioned(
    bottom: 150,
    child: Container(
      width: Engine.screen.width,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          text('You Died'),
          height8,
          container(
            alignment: Alignment.center,
            child: "Respawn",
            action: GameNetwork.sendClientRequestRespawn,
            color: greyDark,
            width: width * goldenRatio_0618,
          )
        ],
      ),
    ),
  );
}