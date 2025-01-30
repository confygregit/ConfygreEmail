import 'dart:ffi';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';

import '../models/user_credential_model.dart';
import 'GlobalVariables.dart';
import 'emails.dart';

UserCredentialModel _userCredentialModel = UserCredentialModel(
    userEmail: userEmail ?? '',
    accessToken: userAccessToken ?? '',
    idToken: userIdToken ?? ''
);

Future<bool> authGoogle() async {

  googleSignIn = signInGoole();

  final googleUser = await googleSignIn.signIn();
  final googleAuth = await googleUser!.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null) {
    throw 'No Access Token found.';
  }
  if (idToken == null) {
    throw 'No ID Token found.';
  }

  _userCredentialModel.accessToken = accessToken.toString();
  _userCredentialModel.idToken = idToken.toString();
  _userCredentialModel.userEmail = googleUser.email;
  objectBox?.updateUserCredential(_userCredentialModel);

  print("auth completed");

  // return supabase.auth.signInWithIdToken(
  //   provider: OAuthProvider.google,
  //   idToken: idToken,
  //   accessToken: accessToken,
  // );

  return true;
}

GoogleSignIn signInGoole(){
  // const webClientId = '446415986013-4mg1uh7kptaodrt17rmv9mak0fv2n5hf.apps.googleusercontent.com'; //OG
  const webClientId = '114911084189-s220mdletf8jo2rvme2q5qt9mknidkvh.apps.googleusercontent.com'; //confygre

  /// TODO: update the iOS client ID with your own.
  ///
  /// iOS Client ID that you registered with Google Cloud.
  // const iosClientId = '584283423841-fc09qt6577ark3k7lvql1o7bjvdlqaqj.apps.googleusercontent.com';
  const iosClientId = '';

  // Google sign in on Android will work without providing the Android
  // Client ID registered on Google Cloud.

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
    scopes: <String>[
      // GmailApi.gmailReadonlyScope,
      GmailApi.gmailComposeScope,
      GmailApi.gmailSendScope,
      GmailApi.gmailModifyScope,
      GmailApi.mailGoogleComScope
    ]
  );

  return googleSignIn;
}

void initSignIn() {
  try{
    // Ensure the user is signed in
    if (googleSignIn.currentUser == null) {
      googleSignIn.signIn();
      print("--------- SIGNED IN ----------");
      print(googleSignIn.currentUser?.id);
    } else {
      print("already signed in");
    }
  } catch(e) {
    print(e);
  }
}