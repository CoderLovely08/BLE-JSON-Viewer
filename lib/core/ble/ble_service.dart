import 'dart:async';
import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// A service class to handle Bluetooth Low Energy (BLE) operations.
class BleService {
  /// Starts scanning for BLE devices.
  ///
  /// [timeout] sets the duration for which to scan. Default is 10 seconds.
  /// [androidScanMode] sets the power mode for Android devices.
  /// [filterByDeviceName] filters devices by name.
  /// [filterByDeviceId] filters devices by ID.
  /// [withServices] filters devices by services they offer.
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
    AndroidScanMode androidScanMode = AndroidScanMode.lowPower,
    List<String> filterByDeviceName = const [],
    List<String> filterByDeviceId = const [],
    List<Guid> withServices = const [],
  }) async {
    try {
      await FlutterBluePlus.startScan(
        androidScanMode: androidScanMode,
        withKeywords: filterByDeviceName,
        withRemoteIds: filterByDeviceId,
        withServices: withServices,
        timeout: timeout,
      );
    } catch (e) {
      log('Error starting BLE scan: $e');
      rethrow;
    }
  }

  /// Stops the ongoing BLE scan.
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      log('Error stopping BLE scan: $e');
      rethrow;
    }
  }

  /// Returns a stream of scan results.
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  /// Connects to a specified BLE device.
  ///
  /// [device] is the BluetoothDevice to connect to.
  Future<void> connectToDevice(
    BluetoothDevice device, {
    bool autoConnect = false,
  }) async {
    try {
      await device.connect(
          autoConnect: autoConnect, mtu: autoConnect ? null : 247);

      // Configure the MTU size
      await device.requestMtu(247);
    } catch (e) {
      log('Error connecting to device: $e');
      rethrow;
    }
  }

  /// Disconnects from a specified BLE device.
  ///
  /// [device] is the BluetoothDevice to disconnect from.
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      log('Error disconnecting from device: $e');
      rethrow;
    }
  }

  /// Returns a stream of device state changes.
  ///
  /// [device] is the BluetoothDevice to monitor.
  Stream<BluetoothConnectionState> deviceState(BluetoothDevice device) {
    return device.connectionState;
  }

  /// Discovers services on a connected device.
  ///
  /// [device] is the BluetoothDevice to discover services on.
  Future<List<BluetoothService>> discoverServices(
      BluetoothDevice device) async {
    try {
      return await device.discoverServices();
    } catch (e) {
      log('Error discovering services: $e');
      rethrow;
    }
  }

  /// Reads the value of a specified characteristic.
  ///
  /// [characteristic] is the BluetoothCharacteristic to read from.
  Future<List<int>> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      return await characteristic.read();
    } catch (e) {
      log('Error reading characteristic: $e');
      rethrow;
    }
  }

  /// Writes a value to a specified characteristic.
  ///
  /// [characteristic] is the BluetoothCharacteristic to write to.
  /// [value] is the List<int> to write.
  Future<void> writeCharacteristic(
      BluetoothCharacteristic characteristic, List<int> value) async {
    try {
      await characteristic.write(value, withoutResponse: false);
    } catch (e) {
      log('Error writing to characteristic: $e');
      rethrow;
    }
  }

  /// Subscribes to notifications from a characteristic.
  ///
  /// [characteristic] is the BluetoothCharacteristic to subscribe to.
  Future<void> subscribeToCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      await characteristic.setNotifyValue(true);
    } catch (e) {
      log('Error subscribing to characteristic: $e');
      rethrow;
    }
  }

  /// Unsubscribes from notifications from a characteristic.
  ///
  /// [characteristic] is the BluetoothCharacteristic to unsubscribe from.
  Future<void> unsubscribeFromCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      await characteristic.setNotifyValue(false);
    } catch (e) {
      log('Error unsubscribing from characteristic: $e');
      rethrow;
    }
  }

  /// Returns a stream of characteristic value changes.
  ///
  /// [characteristic] is the BluetoothCharacteristic to monitor.
  Stream<List<int>> characteristicValue(
      BluetoothCharacteristic characteristic) {
    return characteristic.lastValueStream;
  }

  /// Returns a stream of Bluetooth adapter state changes.
  Stream<BluetoothAdapterState> get bluetoothState =>
      FlutterBluePlus.adapterState;

  /// Checks if a device is currently connected.
  ///
  /// [device] is the BluetoothDevice to check.
  Future<bool> isConnected(BluetoothDevice device) async {
    try {
      var connectedDevices = FlutterBluePlus.connectedDevices;
      return connectedDevices.contains(device);
    } catch (e) {
      log('Error checking device connection: $e');
      rethrow;
    }
  }

  /// Returns a stream of connection state changes for a device.
  ///
  /// [device] is the BluetoothDevice to monitor.
  Stream<BluetoothConnectionState> connectionState(
      BluetoothDevice device) async* {
    // Emit the initial connection state first
    final connectedDevices = FlutterBluePlus.connectedDevices;
    if (connectedDevices.any((d) => d.remoteId == device.remoteId)) {
      yield BluetoothConnectionState.connected;
    } else {
      yield BluetoothConnectionState.disconnected;
    }

    // Now listen for actual connection state changes
    yield* device.connectionState;
  }

  /// Returns a connected device.
  ///
  /// [deviceId] is the ID of the device to get.
  getConnectedDevice() {
    if (FlutterBluePlus.connectedDevices.isNotEmpty) {
      return FlutterBluePlus.connectedDevices.first;
    } else {
      return null;
    }
  }

  /// Returns whether scanning is in progress.
  ///
  /// [device] is the BluetoothDevice to monitor.
  Stream<bool> isScanning() {
    try {
      return FlutterBluePlus.isScanning;
    } catch (e) {
      log('Error checking scan status: $e');
      rethrow;
    }
  }
}
