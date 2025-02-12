import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/ble/ble_service.dart';

final bleServiceProvider = Provider<BleService>((ref) => BleService());

final scanResultsProvider = StreamProvider<List<ScanResult>>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.scanResults;
});

final bluetoothStateProvider = StreamProvider<BluetoothAdapterState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.bluetoothState;
});

final isScanning = StreamProvider<bool>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.isScanning();
});