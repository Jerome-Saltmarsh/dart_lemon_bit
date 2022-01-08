

import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:lemon_watch/watch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache<T> extends Watch<T> {
  final String key;
  Cache({required this.key, required T value}) : super(value){
    onChanged(_onChanged);

    SharedPreferences.getInstance().then((shared){
      if (shared.containsKey(key)){
        value = shared.getAny(key);
        print("cache loaded {key: $key, value: $value}");
      }
    });
  }

  void _onChanged(T t){
      print("cache value changed(key: '$key', value: $value)");
      SharedPreferences.getInstance().then((shared){
        shared.putAny(key, value);
      });
  }
}
