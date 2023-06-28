import 'behavior_node.dart';
import 'condition.dart';

class ConditionNode implements BehaviorNode {
  final Condition condition;

  ConditionNode(this.condition);

  @override
  bool execute() {
    return condition();
  }
}
