import 'package:lemon_engine/lemon_engine.dart';



enum OperationStatus {
  None,
  Authenticating,
  Creating_Account,
  Logging_Out,
  Opening_Secure_Payment_Session,
  Cancelling_Subscription,
  Updating_Account,
  Changing_Public_Name,
  Loading_Map,
  Saving_Map,
  Checking_For_Updates,
}

class FontSize {
  static const VerySmall = Regular * Engine.GoldenRatio_0_381;
  static const Small = Regular * Engine.GoldenRatio_0_618;
  static const Regular = 18.0;
  static const Large = Regular * Engine.GoldenRatio_1_381;
  static const VeryLarge = Large * Engine.GoldenRatio_1_618;
}

