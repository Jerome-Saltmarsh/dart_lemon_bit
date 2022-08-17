

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:golden_ratio/constants.dart';

import '../../../network/send_client_request.dart';
import '../widgets/build_container.dart';

Widget buildWatchPlayerAlive(){
  return watch(player.alive, (bool alive) {
    const width = 300;
     if (alive) return const SizedBox();
     return container(
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
     );
  });
}