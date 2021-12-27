import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/state/game.dart';

bool get playMode => game.mode.value == Mode.Play;
bool get editMode => game.mode.value == Mode.Edit;