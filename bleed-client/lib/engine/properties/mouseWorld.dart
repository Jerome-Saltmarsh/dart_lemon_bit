import 'package:bleed_client/engine/functions/screenToWorld.dart';

import '../GameWidget.dart';

double get mouseWorldX => screenToWorldX(mouseX ?? 0);
double get mouseWorldY => screenToWorldY(mouseY ?? 0);