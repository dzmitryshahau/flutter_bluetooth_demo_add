import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SearchDevicesProvider extends ChangeNotifier {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  Stream<bool> getScanningStateStream() => _flutterBlue.isScanning;
  Stream<List<ScanResult>> getScanResultStream() => _flutterBlue.scanResults;



  void stopSearch() async {
    _flutterBlue.stopScan();
  }

  void startSearch() async {
    _flutterBlue.startScan(
        timeout: const Duration(seconds: 10), scanMode: ScanMode.balanced);
  }
  
}
