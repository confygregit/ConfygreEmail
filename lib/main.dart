import 'package:Confygre_Email/models/oauth_model.dart';
import 'package:Confygre_Email/pages/oAuth_setting_page.dart';
import 'package:flutter/material.dart';
import 'components/objectBox.dart';
import 'pages/intro_screen_page.dart';
import 'pages/list_page.dart';

import 'components/GlobalVariables.dart';
import 'models/app_settings_model.dart';
import 'objectbox.g.dart';
import 'pages/login_page.dart';

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // bool toHome = objectBox!.getComponentsCacheModel();
    bool toHome = true;

    Widget widget = OauthSettingPage();
    OauthModel? oauthModel = objectBox?.getOAuthData();
    if(oauthModel != null)
      widget = LoginPage();

    if(toHome)
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        // home: LoginPage(),
        home: widget,
      );
    else{
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: IntroScreenPage(), // Set IntroScreen as the initial page
      );
    }
  }
}
