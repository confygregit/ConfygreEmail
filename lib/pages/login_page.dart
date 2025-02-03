import 'package:Confygre_Email/pages/oAuth_setting_page.dart';
import 'package:flutter/material.dart';
import '../models/user_credential_model.dart';
import '../pages/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/GlobalVariables.dart';
import '../components/emails.dart';
import '../components/gmail_auth.dart';
import '../components/objectBox.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool sessionStatus = false;

  @override
  void initState() {
    super.initState();
    googleSignIn = signInGoole();

    var userCred = objectBox?.getUserCredential();
    if(userCred != null){
      // Initialize GoogleSignIn
      initSignIn();
    }

    print("${googleSignIn.currentUser?.id} is null");
    googleSignIn.onCurrentUserChanged.listen((data) async {
      print("signed in");
      print(googleSignIn.currentUser?.id);
      String userAccount = googleSignIn.currentUser?.email ?? "";
      try{
        getEmails();
      } catch(e) {
        try{
          googleSignIn.signOut();
          objectBox?.removeUserCredential();
          gettingEmails = false;
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        } catch (ex) {
          print(ex);
        }
      }

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Image.asset('assets/logo.png'),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => {
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OauthSettingPage()));
                  })
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(20),
                  margin:
                  EdgeInsets.only(bottom: 50), // Optional margin for spacing
                  child: Text(
                    'oAuth Setting',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 15,),
              GestureDetector(
                onTap: () {
                  authGoogle();
                  print("signed in");
                  print(googleSignIn.currentUser?.id);
                  String userAccount = googleSignIn.currentUser?.email ?? "";
                  try{
                    googleSignIn.onCurrentUserChanged.listen((data) async {
                      print("signed in");
                      print(googleSignIn.currentUser?.id);
                      String userAccount = googleSignIn.currentUser?.email ?? "";
                      try{
                        getEmails();
                      } catch(e) {
                        print(e);
                      }
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => HomePage()));
                    });
                  } catch(e) {
                    try{
                      googleSignIn.signOut();
                      objectBox?.removeUserCredential();
                      gettingEmails = false;
                      Future.delayed(Duration(seconds: 1), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      });
                    } catch (ex) {
                      print(ex);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(20),
                  margin:
                  EdgeInsets.only(bottom: 50), // Optional margin for spacing
                  child: Text(
                    'Sign In with Google',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
