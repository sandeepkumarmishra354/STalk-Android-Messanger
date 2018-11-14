import 'dart:io';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../utils/enums.dart';
import '../utils/storage.dart';

class StalkNetwork {
  final String _url = "http://192.168.225.103";
  String _loggedin, _login, _upload, _search, _register, _complete, _logout;
  Dio _dioNetwork;
  String _imageFolder;
  String _videoFolder;
  String _audioFolder;
  String _gifFolder;
  bool _isCookieInitiated = false;
  bool get isCookieInitiated => _isCookieInitiated;

  static StalkNetwork instance = new StalkNetwork._internal();

  StalkNetwork._internal() {
    _loggedin = _url + '/is_loggedin';
    _login = _url + '/login';
    _logout = _url + '/logout';
    _upload = _url + "/uploadFile";
    _search = _url + '/search_users';
    _register = _url + '/register/';
    _complete = _url + '/complete_registration';
    _dioNetwork = new Dio();
    initDownloadFolder();
  }

  factory StalkNetwork() => instance;

  Future<dynamic> isLoggedIn() async {
    Response resp;
    try {
      resp = await _dioNetwork.get(_loggedin);
    } on DioError {
      return {"status": STATUS.InternalNetworkError};
    }
    return json.decode(resp.data);
  }

  Future<dynamic> loginUser({
    @required String username,
    @required String password,
  }) async {
    final FormData data = FormData.from({
      'username': username,
      'password': password,
    });
    Response resp;
    try {
      resp = await _dioNetwork.post(
        _login,
        data: data,
      );
    } on DioError {
      return {"status": STATUS.InternalNetworkError};
    }
    print(resp.data);
    return json.decode(resp.data);
  }

  Future<dynamic> logoutUser() async {
    await Storage.instance.init();
    Map data = await Storage.instance.getOtherDetails();
    if(data['username'].isNotEmpty) {
      Response resp;
      try {
        resp = await _dioNetwork.post(
          _logout,
          data: new FormData.from(
            {
              'username': data['username'],
            }
          ),
        );
      }
      on DioError {
        return {"status": STATUS.InternalNetworkError};
      }
      return json.decode(resp.data);
    }
  }

  initDownloadFolder() async {
    Directory extDir = await getExternalStorageDirectory();
    _imageFolder = extDir.path + "/STalk/media/image/";
    _videoFolder = extDir.path + "/STalk/media/video/";
    _audioFolder = extDir.path + "/STalk/media/audio/";
    _gifFolder = extDir.path + "/STalk/media/gif/";
  }

  initiateCookie() async {
    if (!_isCookieInitiated) {
      Directory tmpdir = await getTemporaryDirectory();
      _dioNetwork.cookieJar = new PersistCookieJar(tmpdir.path);
      _isCookieInitiated = true;
    }
  }

  Future<dynamic> uploadFile(
      {@required File imgFile, @required String imgName}) async {
    FormData formData = new FormData.from(
      {
        "profileImage": new UploadFileInfo(imgFile, "random_name"),
        "fileName": imgName,
      },
    );
    Response resp;
    try {
      resp = await _dioNetwork.post(
        _upload,
        data: formData,
        options: new Options(
          contentType: ContentType.parse("multipart/form-data"),
        ),
      );
    } on DioError {
      return {"status": STATUS.InternalNetworkError};
    }
    var result = json.decode(resp.data);
    print(result['status']);
    print(result['fileUrl']);
    return result;
  }

  downloadFile({@required String url, FileType type: FileType.IMAGE}) async {
    var list = url.split('/');
    var filename = list.last;
    String saveLocation = "";
    switch (type) {
      case FileType.AUDIO:
        saveLocation = _audioFolder + filename;
        break;
      case FileType.VIDEO:
        saveLocation = _videoFolder + filename;
        break;
      case FileType.IMAGE:
        saveLocation = _imageFolder + filename;
        break;
      case FileType.GIF:
        saveLocation = _gifFolder + filename;
        break;
    }
    try {
      return _dioNetwork.download(url, saveLocation);
    } on DioError {
      return {"status": STATUS.InternalNetworkError};
    }
  }

  Future<dynamic> searchUser(String keyword) async {
    if (keyword != null && keyword.isNotEmpty) {
      try {
        Response resp =
            await _dioNetwork.get(_search, data: {"keyword": keyword});
        var result = json.decode(resp.data);
        return result;
      } on DioError {
        return {"status": STATUS.InternalNetworkError};
      }
    } else
      return null;
  }

  Future<dynamic> registerPhone(
      {@required String phone, @required String uid}) async {
    try {
      Response resp = await _dioNetwork.post(
        _register,
        data: new FormData.from(
          {
            'phone_no': phone,
            'uid': uid,
          },
        ),
      );
      print(resp.data);
      Map data = json.decode(resp.data);
      print(data);
      return data;
    } on DioError {
      return {"status": STATUS.InternalNetworkError};
    }
  }

  Future<dynamic> completeRegistration({
    @required String username,
    @required String fullname,
    @required int gender,
    @required int age,
    @required String uid,
    @required String number,
    @required String password,
  }) async {
    try {
      Response resp = await _dioNetwork.post(
        _complete,
        data: new FormData.from(
          {
            'username': username,
            'full_name': fullname,
            'gender': gender,
            'age': age,
            'uid': uid,
            'phone_no': number,
            'password': password,
          },
        ),
      );
      return json.decode(resp.data);
    } on DioError {
      return {"status": STATUS.InternalNetworkError};
    }
  }
}
