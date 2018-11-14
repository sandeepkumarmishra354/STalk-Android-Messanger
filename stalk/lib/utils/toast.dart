import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'enums.dart';

class Toast {
  static showToast({
    @required String msg,
    ToastType msgType: ToastType.NORMAL,
    String bgcolor: '#808080',
    String textcolor: '#ffffff',
    ToastGravity gravity: Gravity.bottom,
  }) async {
    Fluttertoast.showToast(
      msg: msg,
      gravity: gravity,
      bgcolor: bgcolor,
      textcolor: (msgType == ToastType.NORMAL)?textcolor:'#FF0000',
    );
  }
}
