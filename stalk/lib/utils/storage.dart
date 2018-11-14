import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../utils/user_data.dart';

class Storage {
  static Storage instance = new Storage._internal();
  bool _initiated = false;
  Storage._internal();
  factory Storage() => instance;
  SharedPreferences _storage;
  Future<void> init() async {
    if (!_initiated) {
      _storage = await SharedPreferences.getInstance();
      _initiated = true;
    }
  }

  User isAlreadyLoggedIn() {
    final String name = _storage.getString("displayName") ?? "";
    final String phoneNo = _storage.getString("phoneNo") ?? "";
    final String photoUrl = _storage.getString("photoUrl") ?? "";
    final String uid = _storage.getString("uid") ?? "";
    if (name.isNotEmpty &&
        phoneNo.isNotEmpty &&
        photoUrl.isNotEmpty &&
        uid.isNotEmpty) {
      return new User(
        photoUrl: photoUrl,
        displayName: name,
        phoneNo: phoneNo,
        uid: uid,
      );
    } else
      return null;
  }

  Future<void> saveUserDetails(var user) async {
    if (user != null) {
      await _storage.setString("displayName", user.displayName);
      await _storage.setString("phoneNo", user.phoneNo);
      await _storage.setString("photoUrl", user.photoUrl);
      await _storage.setString("uid", user.uid);
    } else {
      throw new Exception("Storage save failed... user is null");
    }
  }

  Future<Null> updateUserDetails(
      {String displayName, String photoUrl, String uid, String phoneNo}) async {
    if (displayName != null)
      await _storage.setString('displayName', displayName);
    if (photoUrl != null) await _storage.setString('photoUrl', photoUrl);
    if (uid != null) await _storage.setString('uid', uid);
    if (phoneNo != null) await _storage.setString('phoneNo', phoneNo);
  }

  Future<void> logOutUser() async {
    await _storage.remove("displayName");
    await _storage.remove("phoneNo");
    await _storage.remove("photoUrl");
    await _storage.remove("uid");
  }

  setRegistrationStatus({@required bool status}) async {
    _storage.setBool('status', status);
  }

  getRegistrationStatus() async {
    return _storage.getBool('status');
  }

  saveNumberAndUid(String number, String uid) async {
    await _storage.setString('phoneNo', number);
    await _storage.setString('uid', uid);
  }

  Future<Map> getNumberAndUid() async {
    String number = _storage.getString('phoneNo') ?? "";
    String uid = _storage.getString('uid') ?? "";
    Map data = {'phone_no': number, 'uid': uid};
    return data;
  }

  saveOtherDetails(
      {String fullname,
      String username,
      String password,
      int age,
      int gender}) async {
    _storage.setString('username', username);
    _storage.setString('fullname', fullname);
    _storage.setString('password', password);
    _storage.setInt('age', age);
    _storage.setInt('gender', gender);
  }

  Future<Map> getOtherDetails() async {
    String fullname = _storage.getString('fullname') ?? "";
    String username = _storage.getString('username') ?? "";
    String password = _storage.getString('password') ?? "";
    int age = _storage.getInt('age') ?? 101;
    int gender = _storage.getInt('gender') ?? 101;
    Map data = {
      'username': username,
      'fullname': fullname,
      'password': password,
      'age': age,
      'gender': gender
    };
    return data;
  }
}
