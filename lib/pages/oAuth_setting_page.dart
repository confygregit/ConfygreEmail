import 'package:Confygre_Email/components/GlobalVariables.dart';
import 'package:Confygre_Email/models/oauth_model.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class OauthSettingPage extends StatefulWidget {
  @override
  _OauthSettingPageState createState() => _OauthSettingPageState();
}

class _OauthSettingPageState extends State<OauthSettingPage> {
  @override
  void initState() {
    super.initState();
    setState(() {
      //Get data from localDB
      OauthModel? oauthModel = objectBox?.getOAuthData();
      if(oauthModel != null){
        oAuthKeyValue = oauthModel.oAuthKey;
      }
    });
  }

  final TextEditingController _controller = TextEditingController(text: oAuthKeyValue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Centers content vertically
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "Have your own oAuth key? or use default one. You can chage it later from the settings page.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "oAuth API Key",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // _saveInput;
                      String inputText = _controller.text;
                      oAuthKeyValue = inputText;
                      print("Input: $inputText"); // Print input value to console
                      if(inputText.length == 0){
                        SnackBar snackBar = SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text("oAuth key can't be empty"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        OauthModel oauthModel = new OauthModel(useDefaultKey: false, oAuthKey: inputText);
                        objectBox?.updateOAuthModel(oauthModel);
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900], // Different color for differentiation
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Text("or"),
                  SizedBox(width: 15,),
                  GestureDetector(
                    onTap: () {
                      oAuthKeyValue = "";
                      OauthModel oauthModel = new OauthModel(useDefaultKey: true, oAuthKey: "");
                      objectBox?.updateOAuthModel(oauthModel);
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900], // Different color for differentiation
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Use default key',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: () {

                },
                child: Text(
                  "how to use own oAuth?",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
