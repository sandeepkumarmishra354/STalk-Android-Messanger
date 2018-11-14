import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'dart:async';

class ContactFilter {
  static ContactFilter instance = new ContactFilter._internal();
  ContactFilter._internal();

  bool _initialized = false;
  factory ContactFilter() => instance;
  List<List> _contact = new List<List>();

  Future<Null> init() async {
    _contact.clear();
    await SimplePermissions.requestPermission(Permission.ReadContacts);
    await SimplePermissions.requestPermission(Permission.WriteContacts);
    Iterable<Contact> con = await ContactsService.getContacts();
    con.forEach((Contact c) {
      c.phones.forEach((Item i) {
        String value = "";
        i.value.split(' ').forEach((s) {
          value += s;
        });
        if (value.startsWith("+91")) _fun1(value, c.displayName);

        if (value.length >= 12 && !value.startsWith("+91"))
          _fun2(value, c.displayName);

        if (value.length < 12) _fun3(value, c.displayName);
      });
    });
    _initialized = true;
    //List cList = await getRefreshedContact();
    //UpdateToFirebase.updateContact(cList, _mainUser);
  }

  refresh() async {
    if(_initialized) {
      _initialized = false;
      await init();
    }
  }

  _fun1(String value, String displayName) {
    String tmp = value;
    int i;
    var ntl = new List();
    if (value[3] == '0') {
      tmp = "";
      var tl = value.split("");
      tl.forEach((s) {
        ntl.add(s);
      });
      ntl.removeAt(3);
      ntl.forEach((s) {
        tmp += s;
      });
    }
    for (i = 0; i < _contact.length; i++) {
      if (_contact[i].contains(tmp)) break;
    }
    if (i == _contact.length) _contact.add([displayName, tmp]);
  }

  _fun2(String value, String displayName) {
    String tmp = value;
    var ntl = new List();
    int i;
    if (value[2] == '0') {
      tmp = "";
      var tl = value.split("");
      tl.forEach((s) {
        ntl.add(s);
      });
      ntl.removeAt(2);
      ntl.forEach((s) {
        tmp += s;
      });
    }
    tmp = "+$tmp";
    for (i = 0; i < _contact.length; i++) {
      if (_contact[i].contains(tmp)) break;
    }
    if (i == _contact.length) _contact.add([displayName, tmp]);
  }

  _fun3(String value, String displayName) {
    String tmp = value;
    var ntl = new List();
    int i;
    if (value.startsWith("0")) {
      tmp = "";
      var tl = value.split("");
      tl.forEach((s) {
        ntl.add(s);
      });
      ntl.removeAt(0);
      ntl.forEach((s) {
        tmp += s;
      });
    }
    tmp = "+91$tmp";
    for (i = 0; i < _contact.length; i++) {
      if (_contact[i].contains(tmp)) break;
    }
    if (i == _contact.length) _contact.add([displayName, tmp]);
  }

  Future<List> getContactList() async {
    if(_initialized)
      return _contact;
    else
      return new List();
  }

}
