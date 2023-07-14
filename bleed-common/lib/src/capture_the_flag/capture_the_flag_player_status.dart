

class CaptureTheFlagPlayerStatus {
  static const No_Flag            = 0;
  static const Holding_Team_Flag  = 1;
  static const Holding_Enemy_Flag = 2;

  static String getName(int value){
    return switch(value){
      No_Flag => 'No_Flag',
      Holding_Team_Flag => 'Holding_Team_Flag',
      Holding_Enemy_Flag => 'Holding_Enemy_Flag',
      _ => 'Unknown_CaptureTheFlagPlayerStatus_$value'
    };
  }
}