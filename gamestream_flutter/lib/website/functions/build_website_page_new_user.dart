

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:user_service_client/src.dart';

Widget buildWebsitePageNewUser(){
  return IsometricBuilder(builder: (context, components){
    return GSContainer(
      child: Column(
        children: [
          buildText('username'),
          buildText('password'),
          onPressed(
            action: () async {
              final userId = await UserServiceClient.createUser(
                  url: components.user.userServiceUrl.value,
                  port: 8080,
                  username: 'hello',
                  password: 'world',
              );

              print('userId: $userId');
            },
            child: buildText('register'),
          ),
        ],
      ),
    );
  });
}