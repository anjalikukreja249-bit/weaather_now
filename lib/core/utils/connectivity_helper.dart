import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  const ConnectivityHelper(this._connectivity);

  final Connectivity _connectivity;

  /// Returns `true` when the device has an active network connection.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Stream that emits `true` when online, `false` when offline.
  Stream<bool> get onConnectivityChanged => _connectivity
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}
