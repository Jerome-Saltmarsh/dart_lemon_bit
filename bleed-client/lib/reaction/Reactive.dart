

import 'package:bleed_client/reaction/ReactiveValue.dart';
import 'package:flutter/cupertino.dart';

class Reactive<T> extends StatelessWidget {
  final ReactiveValue<T> value;
  final Widget Function(T t) builder;

  Reactive(this.value, this.builder);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: value.stream,
      initialData: value.value,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        return builder(snapshot.data);
      },
    );
  }
}