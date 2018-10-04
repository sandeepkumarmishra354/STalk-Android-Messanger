import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSingIn = new GoogleSignIn();

  Future<FirebaseUser> signInWithGoogle() async {
    GoogleSignInAccount currentUser = _googleSingIn.currentUser;
    if (currentUser == null) {
      currentUser = await _googleSingIn.signInSilently();
    }
    if (currentUser == null) {
      currentUser = await _googleSingIn.signIn();
    }
    GoogleSignInAuthentication currentAuth = await currentUser.authentication;

    final FirebaseUser user = await _auth.signInWithGoogle(
      idToken: currentAuth.idToken,
      accessToken: currentAuth.accessToken,
    );
    return user;
  }

  Future<Null> signOutWithGoogle() async {
    await _auth.signOut();
    await _googleSingIn.signOut();
  }

  Future<Null> saveDetailsToFirebase(FirebaseUser user) async {
    if (user != null) {
      // check is already signup
      final QuerySnapshot result = await Firestore.instance
          .collection("users")
          .where(
            'uid',
            isEqualTo: user.uid,
          )
          .getDocuments();

      if (result.documents.length == 0) {
        //update data to server if new user
        Firestore.instance.collection("users").document(user.uid).setData(
          {
            'displayName': user.displayName,
            "photoUrl": user.photoUrl,
            "uid": user.uid,
          },
        );
      }
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
}
