import 'package:bleed_client/assertions.dart';
import 'package:bleed_client/common/ClientRequest.dart';

import '../connection.dart';
import '../state.dart';

void sendRequestUseMedKit(){
  assertPlayerAssigned();
  send('${ClientRequest.Player_Use_MedKit.index} $session');
}