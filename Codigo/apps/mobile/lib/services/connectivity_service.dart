import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> isOnline() async {
    final res = await Connectivity().checkConnectivity();

    // Considera Wi-Fi, dados móveis, ethernet e VPN como "online"
    return res == ConnectivityResult.mobile ||
           res == ConnectivityResult.wifi   ||
           res == ConnectivityResult.ethernet ||
           res == ConnectivityResult.vpn;
  }
}
