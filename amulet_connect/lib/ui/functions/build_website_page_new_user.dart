
import 'package:amulet/classes/amulet_connect.dart';
import 'package:amulet/classes/connection_websocket.dart';
import 'package:amulet/ui/enums/website_page.dart';
import 'package:amulet/ui/widgets/gs_textfield.dart';
import 'package:amulet_client/ui/widgets/gs_container.dart';
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:lemon_watch/src.dart';


Widget buildContainerAuthenticate(AmuletConnect amuletApp, ConnectionWebsocket serverRemote){
  final loginPage = WatchBool(true);
  return GSContainer(
    width: 500,
    child: buildWatch(
        loginPage, (login) => Column(
      children: [
        Row(
          children: [
            onPressed(
              action: loginPage.setTrue,
              child: GSContainer(
                color: login ? Colors.white24 : null,
                child: buildText('login'),
              ),
            ),
            width16,
            onPressed(
              action: loginPage.setFalse,
              child: GSContainer(
                color: !login ? Colors.white24 : null,
                child: buildText('register'),
              ),
            ),
            const Expanded(child: SizedBox()),
            onPressed(
              action: (){
                amuletApp.websitePage.value = WebsitePage.New_Character;
              },
              child: buildText('skip', color: Colors.orange, underline: true),
            ),
          ],
        ),
        height16,
        login
            ? buildContainerLogin(serverRemote)
            : buildContainerRegister(serverRemote),

        height16,
      ],
    )
    ),
  );
}

Widget buildContainerLogin(ConnectionWebsocket user){
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  return Column(
    children: [
      GSTextField(
        title: 'username',
        controller: userNameController,
        autoFocus: true,
      ),
      height16,
      GSTextField(
        title: 'password',
        controller: passwordController,
      ),
      height16,
      onPressed(
        action: () async {
          user.login(
            username: userNameController.text,
            password: passwordController.text,
          );
        },
        child: GSContainer(
          color: Colors.green,
          child: buildText('submit'),
        ),
      ),
    ],
  );
}

Widget buildContainerRegister(ConnectionWebsocket serverRemote){
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  return Column(
    children: [
      // GSTextField(
      //   title: 'username',
      //   controller: userNameController,
      //   autoFocus: true,
      // ),
      // height16,
      // GSTextField(
      //   title: 'password',
      //   controller: passwordController,
      // ),
      height16,
      onPressed(
        action: () async {
          serverRemote.register(
            username: userNameController.text,
            password: passwordController.text,
          );
        },
        child: GSContainer(
          color: Colors.green,
          child: buildText('submit'),
        ),
      ),
    ],
  );
}
