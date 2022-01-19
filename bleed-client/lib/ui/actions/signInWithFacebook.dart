import 'package:bleed_client/authentication.dart';
import 'package:bleed_client/user-service-client/userServiceHttpClient.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

bool _initialized = false;

void loginWithFacebook() async {
  if (!_initialized){
    _initialized = true;
    initFacebookAuth();
  }
  final result = await FacebookAuth.instance.login();

  if (result.status == LoginStatus.success){
     final accessToken = result.accessToken;

     if (accessToken == null) throw Exception("access token is null");

      authentication.value = Authentication(userId: accessToken.userId, displayName: 'facebook_user', email: "facebookUser@email.com");
  }
}

void initFacebookAuth(){
  FacebookAuth.instance.webInitialize(
    appId: "652186692488193",
    cookie: true,
    xfbml: true,
    version: "v12.0",
  );
}
