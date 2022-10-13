import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/events/on_changed_ambient_shade.dart';
import 'package:lemon_watch/watch.dart';


final ambientShade = Watch(Shade.Bright, onChanged: onChangedAmbientShade);
var ambientColor = colorShades[Shade.Bright];