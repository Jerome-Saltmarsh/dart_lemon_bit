
import '../connection.dart';
import '../state.dart';
import '../utils.dart';

void requestThrowGrenade(double strength){
  if (!playerAssigned) return;
  send('grenade $playerId $playerUUID ${strength.toStringAsFixed(1)}');
}