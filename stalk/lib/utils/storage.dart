import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../utils/user_data.dart';

class Storage {

  SharedPreferences _storage;
  Future<void> init() async {
    _storage = await SharedPreferences.getInstance();
  }

  User isAlreadyLoggedIn() {
    final String name = _storage.getString("displayName") ?? "";
    final String email = _storage.getString("email") ?? "";
    final String photoUrl = _storage.getString("photoUrl") ?? "";
    final String uid = _storage.getString("uid") ?? "";
    if(name.isNotEmpty && email.isNotEmpty && photoUrl.isNotEmpty && uid.isNotEmpty) {
      return new User(
        photoUrl: photoUrl,
        displayName: name,
        email: email,
        uid: uid,
      );
    }
    else
      return null;
  }

  Future<void> saveUserDetails(FirebaseUser user) async {
    if(user != null) {
      await _storage.setString("displayName", user.displayName);
      await _storage.setString("email", user.email);
      await _storage.setString("photoUrl", user.photoUrl);
      await _storage.setString("uid", user.uid);
    }
    else {
      throw new Exception("Storage save failed... user is null");
    }
  }

  Future<void> logOutUser() async {
    await _storage.remove("displayName");
    await _storage.remove("email");
    await _storage.remove("photoUrl");
    await _storage.remove("uid");
  }

}