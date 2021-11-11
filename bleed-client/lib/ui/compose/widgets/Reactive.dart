

import 'package:bleed_client/classes/ReactiveState.dart';
import 'package:flutter/cupertino.dart';

class Reactive<T> extends StatelessWidget{
  final ReactiveState<T> value;
  final Widget Function(T t) builder;

  Reactive(this.value, this.builder);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: value.stream,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        return builder(snapshot.data );
      },
    );
  }
}