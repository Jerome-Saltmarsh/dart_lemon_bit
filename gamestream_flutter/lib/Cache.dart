

import 'package:lemon_watch/watch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache<T> extends Watch<T> {

  final String key;

  Cache({required this.key, required T value}) : super(value){
    onChanged(_onChanged);
    SharedPreferences.getInstance().then((shared){
      if (shared.containsKey(key)){
        final cachedValue = shared.get(key);
        if (cachedValue is T){
          value = cachedValue;
          print("cache loaded {key: $key, value: $value}");
          return;
        }
        print("Invalid cached value type $cachedValue");
      }
    });
  }

  void _onChanged(T t){
      SharedPreferences.getInstance().then((shared){
        if (t is bool){
          shared.setBool(key, t);
          return;
        }
        if (t is int){
          shared.setInt(key, t);
          return;
        }
        if (t is String){
          shared.setString(key, t);
          return;
        }
        if (t is double){
          shared.setDouble(key, t);
          return;
        }
        if (t is List<String>){
          shared.setStringList(key, t);
          return;
        }
        throw Exception("could not cache value: $t");
      });
  }
}
