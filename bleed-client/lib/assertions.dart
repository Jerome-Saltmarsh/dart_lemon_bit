

import 'package:bleed_client/utils.dart';

void assertPlayerAssigned(){
  if(playerAssigned) return;
  throw NoPlayerAssignedException();
}

class NoPlayerAssignedException implements Exception {

}