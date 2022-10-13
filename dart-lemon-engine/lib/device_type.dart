
class DeviceType {
  static final Phone = 0;
  static final Computer = 1;

  static String getName(int value){
     if (value == Phone){
       return "Phone";
     }
     if (value == Computer){
       return "Computer";
     }
     return "unknown-device-type($value)";
  }
}