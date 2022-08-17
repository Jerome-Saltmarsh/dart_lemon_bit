import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:gamestream_flutter/control/classes/authentication.dart';

var _initialized = false;

Future<Authentication?> getAuthenticationFacebook() async {
  if (!_initialized) {
    _initialized = true;
    initFacebookAuth();
  }
  final result = await FacebookAuth.instance.login();

  if (result.status != LoginStatus.success) {
    return null;
  }

  final accessToken = result.accessToken;

  if (accessToken == null) throw Exception("access token is null");

  final userData =
      await FacebookAuth.instance.getUserData(fields: "name,email");

  final privateName = userData['name'];
  final email = userData['email'];

  return Authentication(
      userId: accessToken.userId, name: privateName, email: email);
}

void initFacebookAuth() {
  FacebookAuth.instance.webInitialize(
    appId: "652186692488193",
    cookie: true,
    xfbml: true,
    version: "v12.0",
  );
}
