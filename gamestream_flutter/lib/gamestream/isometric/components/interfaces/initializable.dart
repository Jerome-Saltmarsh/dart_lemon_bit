
import 'package:shared_preferences/shared_preferences.dart';

abstract class Initializable {
  Future onComponentInitialize(SharedPreferences sharedPreferences);
}