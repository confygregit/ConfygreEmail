import 'package:flutter/material.dart';
import '../models/skipped_emails_history_model.dart';
import '../models/unsubscribed_email_hisotry_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_settings_model.dart';
import '../models/email_data_model.dart';
import '../objectbox.g.dart';
import 'objectBox.dart';
import 'package:intl/intl.dart';

late GoogleSignIn googleSignIn;

String emailId = "";
String emailSubject = "";
String emailSenderName = "loading...";
String emailSenderEmail = "";
String? userAccessToken;
String? userIdToken;
bool isOneClickUnsub = true;
String mailToString = "";
String mailToSubject = "";
String directString = "";
bool isEmailStared = false;
bool isEmailLabeled = false;
bool isEmailImportant = false;
int numberOfEmailsAvailable = 0;
bool gettingEmails = false;

List<String> emailIdsToDelete = [];
Map<String, EmailDataModel> emailDataList = new Map<String, EmailDataModel>();

List<UnsubscribedEmailHisotryModel>? unsubscribedEmails = [];
List<SkippedEmailsHistoryModel>? skippedEmails = [];

bool canGetNextRequest = true;

String dateTimeInUTC = getDateTimeInUTC();
int unsubscribedToday = 0;
int skippedToday = 0;
int deletedToday = 0;
int availableLimit = -1;

int totalUnsubscribedEmails = 0;
int totalSkippedEmails = 0;
int totalDeletedEmails = 0;

// App Settings
//bool unsubscribeAndMoveToTrash = true;
bool permanentDelete = false;
bool blockTheSender = true;
bool deleteAllMailsFromTheSender = true;
bool showSkippedEmails = false;
bool showOnlyUnsubscribableEmails = false;

// Profile
String? userEmail;
String? userName;
String? userId;
String? createdAt;
String? membershipType;

ObjectBox? objectBox;

String? oAuthKeyValue;
String defaultOAuthKeyValue = "";

String getDateTimeInUTC() {
  DateTime nowUtc = DateTime.now().toUtc();
  String formattedDate = DateFormat('ddMMyyyy').format(nowUtc);
  return formattedDate;
}
