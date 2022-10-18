

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/engine.dart';

import '../../../network/send_client_request.dart';
import '../widgets/build_container.dart';

Widget buildContainerRespawn(){
  const width = 300;
  return Container(
    width: Engine.screen.width,
    height: Engine.screen.height,
    alignment: Alignment.center,
    child: container(
      width: width,
      height: width * goldenRatio_0618,
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
            action: sendClientRequestRespawn,
            color: greyDark,
            width: width * goldenRatio_0618,
          )
        ],
      ),
    ),
  );
}