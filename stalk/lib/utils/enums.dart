import 'package:fluttertoast/fluttertoast.dart';

class STATUS {
  static const int Fail = 0;
  static const int Success = 1;
  static const int Error = 2;
  static const int UsernameAlreadyTaken = 3;
  static const int AccountExists = 4;
  static const int NotLoggedIn = 5;
  static const int InternalNetworkError = 101;
  static const int NoNetworkAccess = 404;
}
class Gravity {
  static const center = ToastGravity.CENTER;
  static const top = ToastGravity.TOP;
  static const bottom = ToastGravity.BOTTOM;
}
class Gender {
  static const Male = 0;
  static const Female = 1;
}
enum FileType { IMAGE, VIDEO, AUDIO, GIF }
enum Position { LEFT, RIGHT }
enum InputType { FORM, NORMAL }
enum MessageType { TEXT, IMAGE, VIDEO, AUDIO, GIF }
enum ToastType {ERROR,NORMAL}
