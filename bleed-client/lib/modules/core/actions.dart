
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/modules/modules.dart';

class CoreActions {

  void operationCompleted(){
    core.state.operationStatus.value = OperationStatus.None;
  }
}