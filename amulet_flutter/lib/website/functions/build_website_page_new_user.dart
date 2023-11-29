
import 'package:amulet_flutter/server/src.dart';
import 'package:amulet_flutter/website/website_game.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/gamestream/ui.dart';
import 'package:amulet_flutter/website/enums/website_page.dart';
import 'package:amulet_flutter/website/widgets/gs_textfield.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:lemon_watch/src.dart';

Widget buildContainerAuthenticate(WebsiteGame website, ServerRemote serverRemote){
  final loginPage = WatchBool(true);
  return GSKeyEventHandler(
    child: GSContainer(
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
                  website.websitePage.value = WebsitePage.New_Character;
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
    ),
  );
}

Widget buildContainerLogin(ServerRemote user){
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

Widget buildContainerRegister(ServerRemote serverRemote){
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
