import 'package:connectivity/connectivity.dart';

class Connection {
  ConnectivityResult _connectivityResult;
  init() async {
    _connectivityResult = await new Connectivity().checkConnectivity();
  }

  refresh() async {
    await init();
  }

  bool isNetworkAvailable() {
    if (_connectivityResult != null) {
      if (_connectivityResult == ConnectivityResult.mobile ||
          _connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }
}
