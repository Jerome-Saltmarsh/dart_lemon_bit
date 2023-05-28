
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/classes/audio_loop.dart';
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/game_audio.dart';

import '../../game_widgets.dart';
import 'constants/colors.dart';
import 'widgets/build_container.dart';

Widget buildSounds() =>
  Refresh(() =>
      Column(
        children: gamestream.audio.audioLoops.map(buildAudioLoop).toList(),
      )
  );

Widget buildAudioLoop(AudioLoop audioLoop){
  return Stack(
    children: [
      container(child: audioLoop.name, color: grey),
      container(child: "", width: 200 * audioLoop.volume, color: greyDark),
      container(child: audioLoop.name, color: Colors.transparent),
    ],
  );
}