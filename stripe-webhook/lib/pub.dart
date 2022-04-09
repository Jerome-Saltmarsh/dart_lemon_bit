
import 'package:gcloud/pubsub.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/service_scope.dart' as ss;

const project = 'gogameserver';

void publishMessage({
  required String userId,
  required String subscriptionId
}) async {
  print("publishMessage(userId: '$userId', subscriptionId: '$subscriptionId')");
  final client = await auth.clientViaMetadataServer();
  final pubSub = PubSub(client, project);
  final topic = await pubSub.lookupTopic('demo-topic');
  final message = await topic.publishString(subscriptionId, attributes: {
    "user-id": userId,
    "subscription-id": subscriptionId
  });
  print("message published");
}

void createSubscription() async {
  final client = await auth.clientViaMetadataServer();
  final pubSub = PubSub(client, project);
  final subscription = await pubSub.createSubscription('demo-subscription', 'demo-topic');
  final event = await subscription.pull();


  ss.fork(() async {
    registerPubSubService(pubSub);
  });
}