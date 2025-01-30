import 'dart:ffi';
import 'package:flutter/material.dart';
import '../models/email_string_model.dart';
import '../models/parse_unsubscribe_string_model.dart';
import '../models/skipped_emails_history_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:app_state/app_state.dart';
import 'package:googleapis/gmail/v1.dart' as gMail;
import '../models/email_data_model.dart';
import '../pages/login_page.dart';
import '../pages/tiles_page.dart';
import 'GlobalVariables.dart';
import 'gmail_auth.dart';
import 'dart:convert';

late gMail.GmailApi gmailApi;
List<gMail.Message> messagesList = [];
List<String> excludedEmails = [];

String buildExclusionQuery(List<String> excludedEmails) {
  try {
    // Create a query for excluded emails
    if (excludedEmails.isEmpty) {
      return ''; // No exclusion query if the list is empty
    }

    // Construct exclusion query
    String exclusionQuery = excludedEmails.map((email) => 'from:$email').join(' OR ');

    // Return the complete query to exclude the emails
    return 'NOT ($exclusionQuery)';
  } catch (e) {
    return '';
  }
}

Future<void> getEmails() async {
  try{
    print("getting emails");
    await Future.delayed(Duration.zero); // Ensures this runs asynchronously

    // Get the authenticated headers (await is required)
    final authHeaders = await googleSignIn.currentUser?.authHeaders;

    // Check if authHeaders is null
    if (authHeaders == null) {
      print("Failed to get auth headers. Make sure the user is signed in.");
      return;
    }

    skippedEmails = objectBox?.getSkippedEmailsList();

    // Pass the resolved headers to GoogleAuthClient
    final authenticateClient = GoogleAuthClient(authHeaders);
    gmailApi = gMail.GmailApi(authenticateClient);

    String? nextPageToken;

    // Fetch messages
    do {
      String query = "";
      if(!showSkippedEmails) {
        if(excludedEmails.length > 0)
          excludedEmails.clear();
        if(skippedEmails != null) {
          excludedEmails.addAll(skippedEmails!.map((e) => e.email).toList());
          query = buildExclusionQuery(excludedEmails);
        }
      }

      gMail.ListMessagesResponse results;

      if(query.length == 0){
        results = await gmailApi.users.messages.list(
            "me",
            pageToken: nextPageToken,
        );
      } else {
        results = await gmailApi.users.messages.list(
            "me",
            pageToken: nextPageToken,
            q: query
        );
      }

      //Check if results.messages is not null before iterating
      if (results.messages != null) {
        for (gMail.Message message in results.messages!) {
          gMail.Message detailedMessage = await gmailApi.users.messages.get(
              "me", message.id!,
              $fields: "payload(headers),labelIds,threadId");

          // Extract headers for subject, sender, etc.
          var headers = detailedMessage.payload?.headers;

          EmailDataModel emailData = new EmailDataModel();
          EmailStringModel? emailStringModel = new EmailStringModel();

          emailData.emailId = message.id;

          // Parse headers
          if (headers != null) {
            for (var header in headers) {
              if (header.name == "From") {
                // Extract sender information
                var from = header.value ?? "";

                emailStringModel = processEmailString(from);

                emailData.senderEmail = emailStringModel?.email;
                emailData.senderName = emailStringModel?.name;
              } else if (header.name == "List-Unsubscribe-Post" && header.value == "List-Unsubscribe=One-Click") {
                emailData.isOneClickUnsub = true;
              } else if(header.name == "List-Unsubscribe") {
                //process string
                ParseUnsubscribeStringModel parseUnsubscribeStringResult = parseUnsubscribeString(header.value ?? "");
                emailData.mailToString = parseUnsubscribeStringResult.mailToString;
                emailData.mailToSubject = parseUnsubscribeStringResult.mailToSubject;
                emailData.directString = parseUnsubscribeStringResult.directString;
              }
            }
          }

          print("${emailDataList.containsKey(emailStringModel?.email)} (${emailData.isOneClickUnsub} || ${showOnlyUnsubscribableEmails})");
          if (!emailDataList.containsKey(emailStringModel?.email) && (emailData.isOneClickUnsub || !showOnlyUnsubscribableEmails)) {
            print("in");
            // Extract labels and flags
            emailData.isStared = false;
            emailData.isImportant = false;
            emailData.isLabeled = false;
            emailData.subject = "";

            // Get number of emails available
            emailData.count = 0;

            // Print the details
            print("Email ID: ${emailData.emailId}");
            // print("Sender Name: ${emailData.senderName}");
            // print("Sender Email: ${emailData.senderEmail}");
            // print("Subject: ${emailData.subject}");
            // print("Starred: ${emailData.isStared}");
            // print("Important: ${emailData.isImportant}");
            print("------------------------------------");

            emailDataList[emailStringModel?.email ?? ""] = emailData;
          }

          print("checking next one ${message.id}");
        }
        gettingEmails = false;
      } else {
        print("No messages found.");
      }

      // Update the nextPageToken for the next iteration
      nextPageToken = results.nextPageToken;
    } while (nextPageToken != null && await googleSignIn.isSignedIn());

    if(!await googleSignIn.isSignedIn())
      print("signed out");
    else
      print("closed loop");
  } catch (e) {
    googleSignIn.signOut();
    objectBox?.removeUserCredential();
    gettingEmails = false;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

Future<int> getEmailCount(String emailAddress) async {
  String? nextPageTokenForSingleMail;
  int count = 0;
  emailIdsToDelete.clear();

  do {
    gMail.ListMessagesResponse response = await gmailApi.users.messages.list(
      "me",
      q: 'from:$emailAddress',
      pageToken: nextPageTokenForSingleMail, // Use the token to get the next page
    );

    // Add the number of messages retrieved in the current response
    count += response.messages?.length ?? 0;

    emailIdsToDelete.addAll(response.messages?.map((message) => message.id!).toList() ?? []);

    // Update the nextPageToken for the next iteration
    nextPageTokenForSingleMail = response.nextPageToken;
  } while (nextPageTokenForSingleMail != null); // Continue until there are no more pages

  return count;
}

Future<List<String>> getBulkEmailList(String email) async {
  String? nextPageToken;
  List<String> emailIds = [];
  do {
    gMail.ListMessagesResponse response = await gmailApi.users.messages.list(
      "me",
      q: 'from:$email',
      pageToken: nextPageToken, // Use the token to get the next page
    );

    if (response.messages != null) {
      emailIds.addAll(response.messages!.map((message) => message.id!));
    }

    // Update the nextPageToken for the next iteration
    nextPageToken = response.nextPageToken;
  } while (nextPageToken != null); // Continue until there are no more pages

  return emailIds;
}

ParseUnsubscribeStringModel parseUnsubscribeString(String input) {
  String? mailToString;
  String? mailSubject = "dummy subject"; // Default value for mailSubject
  String? directString;

  ParseUnsubscribeStringModel parseUnsubscribeStringModel = new ParseUnsubscribeStringModel();

  // Split the input by commas to get individual entries
  final parts = input.split(',');

  // Regex to detect mailto and URL
  final mailtoRegex = RegExp(r'mailto:([^>\?]+)'); // Extracts email before `?` or `>`
  final subjectRegex = RegExp(r'subject=([^>\&]+)'); // Extracts subject after `subject=` excluding trailing `>` or `&`
  final urlRegex = RegExp(r'https?://[^\s,>]+');

  for (var part in parts) {
    part = part.trim(); // Trim spaces

    // Check for mailto link
    final mailtoMatch = mailtoRegex.firstMatch(part);
    if (mailtoMatch != null) {
      parseUnsubscribeStringModel.mailToString = mailtoMatch.group(1);

      // Check for subject in the same part
      final subjectMatch = subjectRegex.firstMatch(part);
      if (subjectMatch != null) {
        parseUnsubscribeStringModel.mailToSubject = subjectMatch.group(1);
      }
    }

    // Check for URL
    final urlMatch = urlRegex.firstMatch(part);
    if (urlMatch != null) {
      parseUnsubscribeStringModel.directString = urlMatch.group(0);
    }
  }

  // print('MailTo String: $mailToString');
  // print('Mail Subject: $mailSubject');
  // print('Direct String: $directString');

  return parseUnsubscribeStringModel;

}

void deleteEmail(List<String> messageIds) async {
  //Permanently Delete
  // try{
  //   await gmailApi.users.messages.batchDelete(
  //     gMail.BatchDeleteMessagesRequest(ids: messageIds),
  //     'me',
  //   );
  // } catch(e) {
  //   print(e);
  // }

  try {
    await gmailApi.users.messages.batchModify(
      gMail.BatchModifyMessagesRequest(
        ids: messageIds, // List of message IDs
        addLabelIds: ['TRASH'], // Add the TRASH label to move emails to trash
      ),
      'me',
    );
    print('Messages moved to trash.');
  } catch (e) {
    print('Error moving messages to trash: $e');
  }
}

void blockEmail(String email){

}

void unSubEmail(String mailToString, String mailToSubject, String directString) async {
  String currentUserEmail = googleSignIn.currentUser!.email;
  String body = "This message was automatically generated by Confygre Email.";
  if(mailToString.length != 0 && currentUserEmail.length != 0){
    if(mailToSubject.length != 0) {
      final rawMessage = createEmail(currentUserEmail, mailToString, mailToSubject, body);
      final message = gMail.Message()..raw = rawMessage;
      await gmailApi.users.messages.send(message, 'me');
    } else {
      final rawMessage = createEmail(currentUserEmail, mailToString, "unsubscribe", body);
      final message = gMail.Message()..raw = rawMessage;
      await gmailApi.users.messages.send(message, 'me');
    }
  } else if(directString.length != 0 && currentUserEmail.length != 0) {
    callWebPage(directString);
  }
}

String createEmail(String sender, String recipient, String subject, String body) {
  final message = StringBuffer();
  message.writeln('From: $sender');
  message.writeln('To: $recipient');
  message.writeln('Subject: $subject');
  message.writeln('');
  message.writeln(body);

  return base64UrlEncode(utf8.encode(message.toString()));
}

Future<void> callWebPage(String url) async {
  try {
    final response = await http.get(Uri.parse(url)); // Sends a GET request
    if (response.statusCode == 200) {
      print('Web page called successfully.');
    } else {
      print('Failed to call web page. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while calling web page: $e');
  }
}