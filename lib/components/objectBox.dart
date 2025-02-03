import 'package:Confygre_Email/models/oauth_model.dart';
import 'package:Confygre_Email/pages/oAuth_setting_page.dart';
import 'package:flutter/material.dart';
import '../components/GlobalVariables.dart';
import '../components/emails.dart';
import '../models/checked_emails_model.dart';
import '../models/components_cache_model.dart';
import '../models/playstore_rating_model.dart';
import '../models/skipped_emails_history_model.dart';
import '../models/tiles_data_model.dart';
import '../models/unsubscribed_email_hisotry_model.dart';
import '../models/user_credential_model.dart';
import '../objectbox.g.dart';

import '../models/app_settings_model.dart';

class ObjectBox {
  late final Store _store;
  late final Box<AppSettingsModel> _appSettingsBox;
  late final Box<UserCredentialModel> _userCredentialBox;
  late final Box<UnsubscribedEmailHisotryModel> _unsubscribedEmailListBox;
  late final Box<SkippedEmailsHistoryModel> _skippedEmailListBox;
  late final Box<CheckedEmailsModel> _checkedEmails;
  late final Box<TilesDataModel> _tilesDataBox;
  late final Box<ComponentsCacheModel> _componentsCacheModel;
  late final Box<PlaystoreRatingModel> _playstoreRatingModel;
  late final Box<OauthModel> _oauthModel;

  ObjectBox._init(this._store) {
    _appSettingsBox = Box<AppSettingsModel>(_store);
    _userCredentialBox = Box<UserCredentialModel>(_store);
    _unsubscribedEmailListBox = Box<UnsubscribedEmailHisotryModel>(_store);
    _skippedEmailListBox = Box<SkippedEmailsHistoryModel>(_store);
    _tilesDataBox = Box<TilesDataModel>(_store);
    _checkedEmails = Box<CheckedEmailsModel>(_store);
    _componentsCacheModel = Box<ComponentsCacheModel>(_store);
    _playstoreRatingModel = Box<PlaystoreRatingModel>(_store);
    _oauthModel = Box<OauthModel>(_store);
  }

  static Future<ObjectBox> init() async {
    final store = await openStore();
    print(store.directoryPath);
    return ObjectBox._init(store);
  }

  bool getPlaystoreRatingModel() {
    final response = _playstoreRatingModel.getAll();
    if (response.isNotEmpty) {
      if(response[0].neverShowAgain)
        return false;
      else {
        if(response[0].dateIfNot != dateTimeInUTC && response[0].showAtCount == unsubscribedToday){
          return true;
        } else
          return false;
      }
    }
    else {
      PlaystoreRatingModel playstoreRatingModel = new PlaystoreRatingModel(neverShowAgain: false, showAtCount: 10, dateIfNot: "000000");
      _playstoreRatingModel.put(playstoreRatingModel);
      return false;
    }
  }

  void updatePlaystoreRatingModel(bool neverShow) {
    final response = _playstoreRatingModel.getAll();
    if(response != null){
      response[0].dateIfNot = dateTimeInUTC;
      response[0].neverShowAgain = neverShow;
      _playstoreRatingModel.put(response[0]);
    }
  }

  bool getComponentsCacheModel() {
    final response = _componentsCacheModel.getAll();
    if (response.isNotEmpty)
      return true;
    else{
      ComponentsCacheModel componentsCacheModel = new ComponentsCacheModel(introductionScreen: true);
      _componentsCacheModel.put(componentsCacheModel);
      return false;
    }
  }

  //User Credential
  UserCredentialModel? getUserCredential() {
    final userCredential = _userCredentialBox.getAll();
    if (userCredential.isNotEmpty) {
      return userCredential[0];
    } else {
      return null;
    }
  }

  int? updateUserCredential(UserCredentialModel userCredentialModel) {
    if(getUserCredential() != null)
      userCredentialModel.id = 1;
    _userCredentialBox.put(userCredentialModel);
  }

  void removeUserCredential() {
    _appSettingsBox.removeAll();
    _userCredentialBox.removeAll();
    _unsubscribedEmailListBox.removeAll();
    _skippedEmailListBox.removeAll();
    _checkedEmails.removeAll();
    _tilesDataBox.removeAll();
  }

  //App Settings
  AppSettingsModel? getAppSettings() {
    final settings = _appSettingsBox.get(1);
    if (settings != null) {
      return settings;
    } else {
      return null;
    }
  }

  int? updateAppSettings(AppSettingsModel appSettingsModel) {
    if(getAppSettings() != null)
      appSettingsModel.id = 1;
    _appSettingsBox.put(appSettingsModel);
  }

  //History page
  List<UnsubscribedEmailHisotryModel>? getUnsubscribedEmailsList() {
    final unsubscribedEmails = _unsubscribedEmailListBox.getAll();
    if (unsubscribedEmails.isNotEmpty) {
      return unsubscribedEmails;
    } else {
      return null;
    }
  }

  int? addUnsubscribedEmail(String email, int count, String emailId) {
    _unsubscribedEmailListBox.put(
      new UnsubscribedEmailHisotryModel(email: email, count: count)
    );
    //addEmailToCheckedEmails(emailId);
    unsubscribedEmails?.add(new UnsubscribedEmailHisotryModel(email: email, count: count));
  }

  bool checkUnsubscribedEmail(String email) {
    final query = _unsubscribedEmailListBox.query(UnsubscribedEmailHisotryModel_.email.equals(email)).build();
    final UnsubscribedEmailHisotryModel? result = query.findFirst();
    query.close();
    if(result == null)
      return true;
    else// Always close the query after use
      return false;
  }

  List<SkippedEmailsHistoryModel>? getSkippedEmailsList() {
    final skippedEmails = _skippedEmailListBox.getAll();
    if (skippedEmails.isNotEmpty) {
      return skippedEmails;
    } else {
      return null;
    }
  }

  int? addSkippedEmail(String email, List<String> emailIds) {
    _skippedEmailListBox.put(
        new SkippedEmailsHistoryModel(email: email)
    );

    //add all the emails via bulkAddMethod
    addBulkEmailsToCheckedEmails(emailIds);

    //addEmailToCheckedEmails(emailId);
    skippedEmails?.add(new SkippedEmailsHistoryModel(email: emailId));
  }

  Future<bool> removeSkippedEmail(String email) async {
    try{
      List<String> emailList = await getBulkEmailList(email);
      if (emailList.isEmpty)
        return false; // Return early if the list is empty

      final query1 = _skippedEmailListBox.query(SkippedEmailsHistoryModel_.email.equals(email)).build();
      final SkippedEmailsHistoryModel? result1 = query1.findFirst();
      query1.close();
      if(result1 != null) {
        _skippedEmailListBox.remove(result1.id);
        skippedEmails?.remove(new SkippedEmailsHistoryModel(email: email));
      }

      emailList.forEach((emailId) {
        final query2 = _checkedEmails.query(CheckedEmailsModel_.emailIds.equals(emailId)).build();
        final CheckedEmailsModel? result2 = query2.findFirst();
        query2.close();
        if(result2 != null)
          _checkedEmails.remove(result2.id);
      });

      return true;

    } catch (e) {
      return false;
    }
  }

  bool checkSkippedEmail(String email) {
    final query = _skippedEmailListBox.query(SkippedEmailsHistoryModel_.email.equals(email)).build();
    final SkippedEmailsHistoryModel? result = query.findFirst();
    query.close();
    if(result == null)
      return true;
    else// Always close the query after use
      return false;
  }

  //Tiles page data
  TilesDataModel? getTilesData(String date) {
    final query = _tilesDataBox.query(TilesDataModel_.dateTimeInUTC.equals(date)).build();
    final TilesDataModel? result = query.findFirst();
    query.close(); // Always close the query after use
    return result;
  }

  int? updateTilesData(int unsubscribedToday, int skippedToday, int deletedToday) {
    TilesDataModel? tilesData = getTilesData(dateTimeInUTC);
    if(tilesData != null) {
      _tilesDataBox.put(new TilesDataModel(id: tilesData.id, dateTimeInUTC: dateTimeInUTC, unsubscribed: unsubscribedToday, deleted: deletedToday, skipped: skippedToday));
    } else {
      _tilesDataBox.put(new TilesDataModel(dateTimeInUTC: dateTimeInUTC, unsubscribed: unsubscribedToday, deleted: deletedToday, skipped: skippedToday));
    }
  }

  //Checked EMails
  int? addEmailToCheckedEmails(String emailIds) {
    _checkedEmails.put(
        new CheckedEmailsModel(emailIds: emailIds)
    );
  }

  bool addBulkEmailsToCheckedEmails(List<String> emailIds) {
    if (emailIds.isEmpty)
      return false; // Return early if the list is empty

    // Create a list of CheckedEmailsModel objects
    final List<CheckedEmailsModel> models = emailIds
        .map((emailId) => CheckedEmailsModel(emailIds: emailId))
        .toList();

    // Use putMany to add all models at once
    var result = _checkedEmails.putMany(models);
    if(result.length != 0)
      return true;
    return false;
  }

  bool addBulkEmailsToSkippedEmails(List<String> emailAddresses) {
    if (emailAddresses.isEmpty)
      return false; // Return early if the list is empty

    // Create a list of CheckedEmailsModel objects
    final List<SkippedEmailsHistoryModel> models = emailAddresses
        .map((email) => SkippedEmailsHistoryModel(email: email))
        .toList();

    // Use putMany to add all models at once
    var result = _skippedEmailListBox.putMany(models);
    if(result.length != 0)
      return true;
    return false;
  }

  int? removeEmailFromCheckedEmails(List<String> emailIds) {
    if (emailIds.isEmpty) return 0; // Return early if the list is empty

    final query = _checkedEmails.query(CheckedEmailsModel_.emailIds.oneOf(emailIds)).build();

    final List<CheckedEmailsModel> results = query.find();
    query.close();

    for (final result in results) {
      _checkedEmails.remove(result.id);
    }

    return results.length;
  }

  //Add bulk emailsIds to objectBox CheckedList

  bool checkCheckedEmailList(String emailIds) {
    final settings = _checkedEmails.getAll();
    final query = _checkedEmails.query(CheckedEmailsModel_.emailIds.equals(emailIds)).build();
    final CheckedEmailsModel? result = query.findFirst();
    query.close();
    if(result == null)
      return true;
    else// Always close the query after use
      return false;
  }

  // OAuth Data
  OauthModel? getOAuthData() {
    final oAuth = _oauthModel.getAll();
    if (oAuth.isNotEmpty) {
      return oAuth[0];
    } else {
      return null;
    }
  }

  int? updateOAuthModel(OauthModel oAuth) {
    if(getOAuthData() != null)
      oAuth.id = 1;
    _oauthModel.put(oAuth);
  }
}
