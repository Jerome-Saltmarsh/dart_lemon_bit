
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/library.dart';


final engine = Engine(
    title: "GAMESTREAM ONLINE",
    init: gamestream.init,
    buildUI: GameWebsite.buildUI,
    buildLoadingScreen: GameWebsite.buildLoadingPage,
    themeData: ThemeData(fontFamily: 'VT323-Regular'),
    backgroundColor: GameIsometricColors.black,
    onError: Gamestream.onError,
    update: (){},
    render: (canvas, size) {

    }
);

