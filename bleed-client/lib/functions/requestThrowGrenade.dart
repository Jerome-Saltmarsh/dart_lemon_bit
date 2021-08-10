
import 'package:bleed_client/enums/ClientRequest.dart';

import '../connection.dart';
import '../state.dart';
import '../utils.dart';

void requestThrowGrenade(double strength){
  if (!playerAssigned) return;
  send('${ClientRequest.Player_Throw_Grenade.index} $session ${strength.toStringAsFixed(1)}');
}