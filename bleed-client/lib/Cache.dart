

import 'package:bleed_client/state/sharedPreferences.dart';
import 'package:lemon_watch/watch.dart';

class Cache<T> extends Watch<T> {
  final String key;
  Cache({required this.key, required T value}) : super(value){
    onChanged(_onChanged);
    if (storage.contains(key)){
      value = storage.get(key);
    }
  }

  void _onChanged(T t){
      storage.put(key, t);
  }
}