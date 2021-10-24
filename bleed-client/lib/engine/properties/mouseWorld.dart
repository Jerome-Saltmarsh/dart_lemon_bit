import 'package:bleed_client/engine/functions/convertScreenToWorld.dart';

import '../render/game_widget.dart';

double get mouseWorldX => convertScreenToWorldX(mouseX ?? 0);
double get mouseWorldY => convertScreenToWorldY(mouseY ?? 0);