import 'dart:ffi';
import 'package:flutter/material.dart';
import '../models/tiles_data_model.dart';
import '../components/GlobalVariables.dart';
import 'dart:math';
import '../components/emails.dart';
import '../components/gmail_auth.dart';
import '../models/email_string_model.dart';
import 'login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Tiles extends StatefulWidget {
  const Tiles({super.key});

  @override
  State<Tiles> createState() => _TilesState();
}

EmailStringModel? processEmailString(String input) {
  try {
    EmailStringModel emailStringModel = new EmailStringModel();
    if (input.contains('<') && input.contains('>')) {
      final name = input.substring(0, input.indexOf('<')).trim();
      final email = input.substring(input.indexOf('<') + 1, input.indexOf('>')).trim();
      emailStringModel.name = name;
      emailStringModel.email = email;
      return emailStringModel;
    } else {
      final name = input.substring(0, input.indexOf('@')).trim();
      final email =
          input.substring(input.indexOf('@') + 1, input.length).trim();
      emailStringModel.name = name;
      emailStringModel.email = email;
      return emailStringModel;
    }
  } catch (e) {
    return null;
  }
}

class _TilesState extends State<Tiles> {
  @override
  void initState() {
    super.initState();
    checkNewVersion();
    setState(() {
      TilesDataModel? tilesData = objectBox?.getTilesData(dateTimeInUTC);
      if (tilesData != null) {
        unsubscribedToday = tilesData.unsubscribed;
        // unsubscribedToday = 43;
        // deletedToday = 389;
        deletedToday = tilesData.deleted;
        skippedToday = tilesData.skipped;
      }
    });
    showEmailDataOrWait();
  }

  void checkNewVersion() async {
    // String newVersion = await checkAppVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    // if(newVersion != currentVersion){
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text('New update is available!'),
    //       content: Text(
    //           'Current version: ${currentVersion} \nNew version: ${newVersion}'),
    //       actions: [
    //         ElevatedButton(
    //           onPressed: () async {
    //             String url = "https://google.com/";
    //             try{
    //               Uri uri = Uri.parse(url);
    //               await launchUrl(
    //                 uri, mode: LaunchMode.externalApplication,
    //               );
    //             } catch (ex) {
    //               print(ex);
    //             }
    //           },
    //           child: Text(
    //             'update now',
    //             style: TextStyle(color: Colors.white),
    //           ),
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: Colors.grey[900],
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }
  }

  void chekPlaystoreDialog() {
    bool toShow = objectBox!.getPlaystoreRatingModel();
    if(toShow){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Its easy to clear emails right? 😉'),
          content: Text(
              'Would you give us a rating in play store?'),
          actions: [
            TextButton(
              onPressed: () {
                objectBox?.updatePlaystoreRatingModel(true);
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'will never do',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                objectBox?.updatePlaystoreRatingModel(false);
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'maybe later',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try{
                  objectBox?.updatePlaystoreRatingModel(true);
                  String url = "https://google.com/";
                  try{
                    Uri uri = Uri.parse(url);
                    await launchUrl(
                    uri, mode: LaunchMode.externalApplication,
                    );
                  } catch (ex) {
                    print(ex);
                  }
                } catch (ex) {
                  print(ex);
                }
              },
              child: Text(
                'sure, lets go!',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> showEmailDataOrWait() async {
    if (emailDataList.isNotEmpty) {
      // Update the UI once emailDataList is populated

      int emailCount = await getEmailCount(emailDataList.entries.first.value.senderEmail!);

      setState(() {
        emailId = emailDataList.entries.first.value.emailId!;
        emailSubject = emailDataList.entries.first.value.subject!;
        emailSenderName = emailDataList.entries.first.value.senderName!;
        emailSenderEmail = emailDataList.entries.first.value.senderEmail!;
        isEmailStared = emailDataList.entries.first.value.isStared;
        isEmailImportant = emailDataList.entries.first.value.isImportant;
        // numberOfEmailsAvailable = emailDataList.entries.first.value.count;
        numberOfEmailsAvailable = emailCount;
        isOneClickUnsub = emailDataList.entries.first.value.isOneClickUnsub;
        mailToString = emailDataList.entries.first.value.mailToString ?? "";
        mailToSubject = emailDataList.entries.first.value.mailToSubject ?? "";
        directString = emailDataList.entries.first.value.directString ?? "";
      });
    } else {
      // Recheck after a delay
      setState(() {
        emailSubject = "...";
        emailSenderName = "loading...";
        emailSenderEmail = "";
        numberOfEmailsAvailable = 0;
      });
      if (!gettingEmails) {
        gettingEmails = true;
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
      }
      Future.delayed(Duration(milliseconds: 1000), showEmailDataOrWait);
    }
  }

  @override
  void unsubscribeEmail(String email, int count, String emailId) {
    if(email.length > 0) {
      objectBox?.addUnsubscribedEmail(email, count, emailId);
      emailDataList.remove(email);

      //Unsub EMail
      unSubEmail(mailToString, mailToSubject, directString);

      //Block EMail
      if(blockTheSender)
        blockEmail(email);

      //Delete Emails
      deleteEmail(emailIdsToDelete);

      setState(() {
        unsubscribedToday += 1;
        deletedToday += count;
        objectBox?.updateTilesData(unsubscribedToday, skippedToday, deletedToday);
      });

      // insertOrUpdateUnsubscribedEmails(email, count);

      showEmailDataOrWait();

      setState(() {
        canGetNextRequest = true;
      });
    }
  }

  void skipEmail(String email, String emailId) async {
    if(email.length > 0) {
      List<String> bulkEmailList = await getBulkEmailList(email);
      objectBox?.addSkippedEmail(email, bulkEmailList);
      emailDataList.remove(email);

      setState(() {
        skippedToday += 1;
        objectBox?.updateTilesData(unsubscribedToday, skippedToday, deletedToday);
      });

      // insertOrUpdateSkippedEmails(email);

      showEmailDataOrWait();

      setState(() {
        canGetNextRequest = true;
      });
    }
  }

  void deleteEmails(String email, int count){
    if(email.length > 0) {
      emailDataList.remove(email);
      deleteEmail(emailIdsToDelete);

      setState(() {
        deletedToday += count;
        objectBox?.updateTilesData(unsubscribedToday, skippedToday, deletedToday);
      });

      // insertOrUpdateDeletedEmails(email, count);

      showEmailDataOrWait();

      setState(() {
        canGetNextRequest = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          //Today Count
          Text("Today's Data"),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 5), // Add margin for spacing
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Unsubscribed',
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                        Text(
                          unsubscribedToday.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 5), // Add margin for spacing
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Deleted',
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                        Text(
                          deletedToday.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Expanded(
                //   child: Container(
                //     margin: EdgeInsets.symmetric(horizontal: 5), // Add margin for spacing
                //     padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           'Available',
                //           style: TextStyle(fontSize: 10, color: Colors.black),
                //         ),
                //         Text(
                //           availableLimit == -1 ? '∞' : availableLimit.toString(),
                //           style: TextStyle(
                //             fontSize: 20,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.black,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          //Tile
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25, bottom: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    emailSenderName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    emailSenderEmail,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      const SizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                emailSenderEmail,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              content: Text(
                                                  'asdasdasd\nasdasdasd aasdasd\nasdasdasd'),
                                            ),
                                          );
                                        },
                                        child: Text.rich(TextSpan(children: [
                                          TextSpan(
                                            text: numberOfEmailsAvailable.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " email(s)",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ])),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Row( // Buttons at the bottom
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if(canGetNextRequest && isOneClickUnsub){
                                    setState(() {
                                      canGetNextRequest = false;
                                    });
                                    unsubscribeEmail(emailSenderEmail, numberOfEmailsAvailable, emailId);
                                  }
                                },
                                child: Container(
                                  height: 50, // Optional height for buttons
                                  decoration: BoxDecoration(
                                    color: isOneClickUnsub ? Colors.red : Colors.grey,
                                    borderRadius: BorderRadius.circular(12), // Optional rounded corners
                                  ),
                                  alignment: Alignment.center, // Center the text inside the container
                                  child: Text(
                                    'Unsub + Delete',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), // Styling for the text
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row( // Buttons at the bottom
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: GestureDetector(
                              onTap: () {
                                if(canGetNextRequest){
                                  setState(() {
                                    canGetNextRequest = false;
                                  });
                                  deleteEmails(emailSenderEmail, numberOfEmailsAvailable);
                                }
                              },
                              child: Container(
                                height: 50, // Optional height for buttons
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12), // Optional rounded corners
                                ),
                                alignment: Alignment.center, // Center the text inside the container
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white, fontSize: 16), // Styling for the text
                                ),
                              ),
                            )
                          ),
                          const SizedBox(width: 10), // Optional spacing between buttons
                          Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if(canGetNextRequest){
                                    setState(() {
                                      canGetNextRequest = false;
                                    });
                                    skipEmail(emailSenderEmail, emailId);
                                  }
                                },
                                child: Container(
                                  height: 50, // Optional height for buttons
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12), // Optional rounded corners
                                  ),
                                  alignment: Alignment.center, // Center the text inside the container
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(color: Colors.white, fontSize: 16), // Styling for the text
                                  ),
                                ),
                              )
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(padding: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(
              color: Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }
}
