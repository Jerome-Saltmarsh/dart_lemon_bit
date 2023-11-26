

import 'package:flutter/cupertino.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class GSButton extends StatelessWidget {
   final Widget child;
   final Function? action;

  const GSButton({super.key, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return onPressed(child: child, action: action);
  }


}