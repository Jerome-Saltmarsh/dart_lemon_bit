import 'package:bleed_client/assertions.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/network/functions/send.dart';

import '../state.dart';

void sendRequestUseMedKit(){
  assertPlayerAssigned();
  send('${ClientRequest.Medkit.index} $session');
}