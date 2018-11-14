import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'storage.dart';
import 'toast.dart';
import 'connection.dart';
import 'enums.dart';

class UpdateToFirebase {
  static Connection connection = new Connection();
  static updateChatList({
    String phoneNo,
    String localName,
    String uid,
    String photoUrl,
    String mainUser,
    bool forceUpdate: false,
  }) async {
    if(await connection.isOnline()) {
      Map<String, String> data = new Map<String, String>();
    if (phoneNo != null) data['phoneNo'] = phoneNo;
    if (localName != null) data['local_name'] = localName;
    if (uid != null) data['uid'] = uid;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .document(mainUser)
        .collection('chat_list')
        .where('phoneNo', isEqualTo: phoneNo)
        .getDocuments();

    if (result.documents.length == 0 || forceUpdate) {
      Firestore.instance
          .collection('users')
          .document(mainUser)
          .collection('chat_list')
          .document(phoneNo)
          .setData(data);
    }
    }
    else
      Toast.showToast(msg: "Network unavailable !!");
  }

  static updateProfileImage(File img, String user) async {
    if (img != null) {
      String url;
      if (await connection.isOnline()) {
        try {
          final StorageReference sref =
              FirebaseStorage.instance.ref().child("profile_images/$user.jpg");
          final StorageUploadTask suTask = sref.putFile(img);
          var uri = await sref.getDownloadURL();
          url = uri.toString();
          await Firestore.instance
              .collection('users')
              .document(user)
              .updateData({
            'photoUrl': url,
          });

          Storage storage = new Storage();
          await storage.init();
          storage.updateUserDetails(
            photoUrl: url,
          );
          Toast.showToast(msg: "Profile picture updated");
        } catch (e) {
          print(e.message);
          Toast.showToast(
            msg: "Profile picture update failed",
            msgType: ToastType.ERROR,
          );
        }
      } else
          Toast.showToast(msg: "Network unavailable !!");
    }
  }

  static Future<bool> deleteAccount(String phoneNo) async {
    if (await connection.isOnline()) {
      try {
        await Firestore.instance.collection('users').document(phoneNo).delete();
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        if (user != null) await user.delete();
        Storage s = new Storage();
        await s.init();
        await s.logOutUser();
        try {
          await FirebaseStorage.instance
              .ref()
              .child("profile_images/$phoneNo.jpg")
              .delete();
        } catch (e) {
          print(e.message);
        }
        Toast.showToast(msg: "Account ${user.phoneNumber} deleted");
        return true;
      } catch (e) {
        print(e.message);
        Toast.showToast(
          msg: "Account deletion failed",
          msgType: ToastType.ERROR,
        );
        return false;
      }
    }
    else {
      Toast.showToast(msg: "Network unavailable !!");
      return false;
    }
  }
}
