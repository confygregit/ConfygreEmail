import 'package:flutter/material.dart';
import '../components/GlobalVariables.dart';
import '../components/GlobalVariables.dart';
import '../models/skipped_emails_history_model.dart';
import '../models/unsubscribed_email_hisotry_model.dart';

import '../components/bottom_nav_bar.dart';
import 'app_settings_page.dart';
import 'home_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedHistoryPageIndex = 0;
  List<dynamic>? finalList = [];
  int totalUnsubscribedEmailsCount = 0;
  int totalskippedEmailsCount = 0;
  String listHeading = "Unsubscribed Email List";

  @override
  void initState() {
    super.initState();
    setState(() {
      //Get data from localDB
      unsubscribedEmails = objectBox?.getUnsubscribedEmailsList();
      skippedEmails = objectBox?.getSkippedEmailsList();
      finalList = List.from(unsubscribedEmails ?? []);
      totalUnsubscribedEmailsCount = unsubscribedEmails?.length ?? 0;
      totalskippedEmailsCount = skippedEmails?.length ?? 0;
    });
  }

  void navigationBetweenList(int index) {
    setState(() {

      if (index == 0) {
        listHeading = "Unsubscribed Email List";
        finalList = List.from(unsubscribedEmails ?? []);
      } else if (index == 1) {
        listHeading = "Skipped Email List";
        finalList = List.from(skippedEmails ?? []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => {navigationBetweenList(0)},
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 5), // Add margin for spacing
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Unsubscribed',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                          Text(
                            totalUnsubscribedEmailsCount.toString(),
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
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () => {navigationBetweenList(1)},
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 5), // Add margin for spacing
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Skipped',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        Text(
                          totalskippedEmailsCount.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),

          //List heading
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              listHeading,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          //Emails list
          Expanded(
              child: Container(
            decoration: BoxDecoration(),
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListView.builder(
                  itemCount: finalList?.length ?? 0,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    if(listHeading == "Unsubscribed Email List"){
                      final emailModel = finalList![index] as UnsubscribedEmailHisotryModel;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              emailModel.email + ' : ' + emailModel.count.toString(),
                              style: TextStyle(fontSize: 20),
                            ),
                          )
                        ],
                      );
                    } else {
                      final emailModel = finalList![index] as SkippedEmailsHistoryModel;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    emailModel.email,
                                    style: TextStyle(fontSize: 20),
                                    overflow: TextOverflow.ellipsis, // Handles long text gracefully
                                  ),
                                ),
                                SizedBox(width: 8), // Optional spacing between the text and the container
                                GestureDetector(
                                  onTap: () async {
                                    if(totalskippedEmailsCount > 0) {
                                      bool? result = await objectBox?.removeSkippedEmail(emailModel.email);
                                      if(result ?? false){
                                        setState(() {
                                          totalskippedEmailsCount -= 1;
                                        });
                                        SnackBar snackBar = SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text("${emailModel.email} removed"),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    }
                                  },
                                  child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Add padding inside the container
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                                      ),
                                      child: Icon(Icons.remove_circle_rounded)
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                      );

                    }
                  }),
            ),
          )),

          //Drawer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(
              color: Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }
}
