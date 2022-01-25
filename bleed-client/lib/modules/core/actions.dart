
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/core/enums.dart';

class CoreActions {

  void operationCompleted(){
    core.state.operationStatus.value = OperationStatus.None;
  }
}