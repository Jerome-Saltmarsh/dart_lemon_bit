import 'action.dart';
import 'behavior_node.dart';

class ActionNode implements BehaviorNode {
  final Action action;

  ActionNode(this.action);

  @override
  bool execute() {
    action();
    return true;
  }
}
