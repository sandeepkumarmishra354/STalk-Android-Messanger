import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_widget.dart';
import '../utils/update_firebase.dart';

enum ViewMode { NORMAL, PROFILE }

class PhotoViewer extends StatelessWidget {
  final String imgUrl;
  final String phoneNo;
  final ViewMode mode;
  PhotoViewer({this.imgUrl, this.mode: ViewMode.NORMAL, this.phoneNo});
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: (mode == ViewMode.NORMAL)
          ? new AppBar()
          : _profileViewAppBar(context),
      body: (mode == ViewMode.NORMAL) ? _normalView() : _profileView(),
    );
  }

  _normalView() {
    if (imgUrl == null)
      throw new Exception("ERROR:: IMAGE URL CAN NOT BE A NULL VALUE");
    else
      return Container(
        child: PhotoView(
          imageProvider: (imgUrl != null)
              ? CachedNetworkImageProvider(imgUrl)
              : AssetImage('images/not-found.jpeg'),
        ),
      );
  }

  _profileView() {
    return new StreamBuilder(
      stream:
          Firestore.instance.collection('users').document(phoneNo).snapshots(),
      builder: (context, ss) {
        if (ss.hasData) {
          return new PhotoView(
            imageProvider: (ss.data != null)
                ? CachedNetworkImageProvider(ss.data['photoUrl'])
                : AssetImage('images/not-found.jpeg'),
          );
        } else
          return new CircularProgressIndicator();
      },
    );
  }

  _profileViewAppBar(BuildContext context) {
    return new AppBar(
      title: new Text("Profile Picture"),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.edit),
          onPressed: () async {
            _photoTapped(context);
          },
        ),
      ],
    );
  }

  _photoTapped(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => new SimpleDialog(
            title: new Text("choose option"),
            children: <Widget>[
              CustomWidget.flatBtn("Open Camera", callback: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              }),
              new Divider(),
              CustomWidget.flatBtn("Open Gallery", callback: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              }),
            ],
          ),
    );
  }

  _pickImage(ImageSource source) async {
    File img = await ImagePicker.pickImage(source: source);
    if (img != null) {
      UpdateToFirebase.updateProfileImage(img, phoneNo);
    }
  }
}
