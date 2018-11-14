import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';

class AuthService {

  static AuthService instance = new AuthService._internal();
  AuthService._internal();
  factory AuthService(){
    return instance;
  }

  Future<Null> saveDetailsToFirebase(var user) async {
    if (user != null) {
      // check is already signup
      final QuerySnapshot result = await Firestore.instance
          .collection("users")
          .where(
            'phoneNo',
            isEqualTo: user.phoneNo,
          )
          .getDocuments();

      if (result.documents.length == 0) {
        //update data to server if new user
        Firestore.instance.collection("users").document(user.phoneNo).setData(
          {
            'displayName': user.displayName,
            "photoUrl": user.photoUrl,
            "uid": user.uid,
            "phoneNo": user.phoneNo,
          },
        );
      }
    }
  }

  Future<Null> updateUserDetailsToFirebase(String phn,
      {String displayName, String photoUrl, String uid, String phoneNo}) async {
    Map<String, String> newDetails = new Map<String, String>();
    if (displayName != null) newDetails['displayName'] = displayName;
    if (photoUrl != null) newDetails['photoUrl'] = photoUrl;
    if (uid != null) newDetails['uid'] = uid;
    if (phoneNo != null) newDetails['phoneNo'] = phoneNo;

    if (newDetails.length > 0) {
      Firestore.instance.collection("users").document(phn).setData(newDetails);
    }
  }

  static sendMessage(
      {String from,
      String to,
      String content,
      String chatId,
      int type,
      File img}) async {
    //type 0 means text
    if (type == 0) {
      var docRef = Firestore.instance
          .collection('messages')
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((tr) async {
        await tr.set(docRef, {
          'from': from,
          'to': to,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'type': 0,
        });
      });
    }
    //type 1 means image
    if (type == 1 && img != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask storageUploadTask = reference.putFile(img);
      String downloadUrl;
      storageUploadTask.onComplete.then((val) async {
        downloadUrl = (await reference.getDownloadURL()).toString();
        var docRef = Firestore.instance
            .collection('messages')
            .document(chatId)
            .collection(chatId)
            .document(fileName); //timestamp

        Firestore.instance.runTransaction((tr) async {
          await tr.set(docRef, {
            'from': from,
            'to': to,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': downloadUrl,
            'type': 1,
          });
        });
      });
    }
  }

  static Future<String> getAppVersion() async {
    QuerySnapshot result = await Firestore.instance
    .collection('version').getDocuments();
    String ver = result.documents[0]['app-version'];
    return ver;
  }

  Future<FirebaseUser> checkExistance(String phoneNo) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if(user != null && user.phoneNumber == phoneNo)
      return user;
    else
      return null;
  }

}
