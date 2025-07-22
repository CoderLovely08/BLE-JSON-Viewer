# BLE Tester - A Comprehensive Flutter BLE Application

A complete Flutter application demonstrating how to build a robust Bluetooth Low Energy (BLE) application using **FlutterBluePlus** and **Riverpod** for state management. This project serves as an educational resource for developers looking to implement BLE functionality in their Flutter applications.

## 🔥 What You'll Learn

- **Complete BLE Implementation** with FlutterBluePlus
- **State Management** using Riverpod providers
- **Real-time notifications** and live data streaming
- **Connection management** and error handling
- **Service discovery** and characteristic interaction
- **Clean architecture** patterns for BLE apps

## 🚀 Features

- ✅ **Device Scanning**: Discover nearby BLE devices with real-time updates
- ✅ **Connection Management**: Connect/disconnect with automatic navigation
- ✅ **Service Discovery**: Automatically discover and display device services
- ✅ **Live Notifications**: Subscribe to characteristic notifications for real-time data
- ✅ **Data Visualization**: Display raw data in both UTF-8 and hexadecimal formats
- ✅ **Connection State Monitoring**: Visual indicators for connection status
- ✅ **Error Handling**: Comprehensive error handling with user feedback

## 📱 Screenshots & Demo

The app provides a clean, intuitive interface for BLE device interaction:
- **Scan Screen**: Lists available BLE devices with connection buttons
- **Services Screen**: Shows discovered services and characteristics
- **Data View**: Real-time display of characteristic values and notifications

## 🏗️ Architecture Overview

### Core Components

```
lib/
├── core/
│   └── ble/
│       └── ble_service.dart          # Core BLE operations service
├── providers/
│   └── ble/
│       └── bluetooth_provider.dart   # Riverpod providers for BLE state
├── screens/
│   ├── scan/
│   │   ├── scan_screen.dart          # Device scanning interface
│   │   └── widgets/
│   │       └── connection_button.dart # Smart connection widget
│   └── data/
│       ├── services_screen.dart      # Service discovery screen
│       └── view_data_screen.dart     # Live data visualization
└── widgets/
    └── common/
        └── custom_snack_bar.dart     # User feedback system
```

## 🔧 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  riverpod: ^2.6.1              # State management
  flutter_riverpod: ^2.6.1     # Flutter integration for Riverpod
  flutter_blue_plus: ^1.35.2   # BLE functionality
```

## 🛠️ Setup & Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/CoderLovely08/BLE-JSON-Viewer
   cd ble_tester
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Platform-specific setup**

   **Android** (android/app/src/main/AndroidManifest.xml):
   ```xml
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
                    android:usesPermissionFlags="neverForLocation" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   ```

   **iOS** (ios/Runner/Info.plist):
   ```xml
   <key>NSBluetoothAlwaysUsageDescription</key>
   <string>This app needs Bluetooth to connect to BLE devices</string>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access to scan for BLE devices</string>
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 💻 Code Deep Dive

### 1. BLE Service Layer (`ble_service.dart`)

The `BleService` class encapsulates all BLE operations, providing a clean interface for the UI layer:

```dart
class BleService {
  // Scanning operations
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
    AndroidScanMode androidScanMode = AndroidScanMode.lowPower,
    List<String> filterByDeviceName = const [],
    List<String> filterByDeviceId = const [],
    List<Guid> withServices = const [],
  });

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // Connection management
  Future<void> connectToDevice(BluetoothDevice device, {bool autoConnect = false});
  Future<void> disconnectFromDevice(BluetoothDevice device);
  Stream<BluetoothConnectionState> connectionState(BluetoothDevice device);

  // Service & Characteristic operations
  Future<List<BluetoothService>> discoverServices(BluetoothDevice device);
  Future<void> subscribeToCharacteristic(BluetoothCharacteristic characteristic);
  Stream<List<int>> characteristicValue(BluetoothCharacteristic characteristic);
}
```

**Key Features:**
- **MTU Configuration**: Automatically requests 247 bytes MTU for optimal data transfer
- **Error Handling**: Comprehensive try-catch blocks with logging
- **Stream-based Architecture**: Reactive programming with Stream APIs

### 2. Riverpod State Management (`bluetooth_provider.dart`)

Riverpod providers manage BLE state reactively across the application:

```dart
// Core service provider
final bleServiceProvider = Provider<BleService>((ref) => BleService());

// Scan results stream
final scanResultsProvider = StreamProvider<List<ScanResult>>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.scanResults;
});

// Connection state for specific device
final connectionStateProvider = 
    StreamProvider.family<BluetoothConnectionState, BluetoothDevice>((ref, device) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.connectionState(device);
});

// Characteristic value notifications
final characteristicValueProvider =
    StreamProvider.family<List<int>, BluetoothCharacteristic>((ref, characteristic) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.characteristicValue(characteristic);
});
```

**State Management Benefits:**
- **Automatic Rebuilds**: UI automatically updates when BLE state changes
- **Family Providers**: Manage state for specific devices/characteristics
- **Stream Integration**: Seamless integration with BLE's async nature

### 3. Smart Connection Widget (`connection_button.dart`)

The connection button demonstrates advanced Riverpod patterns:

```dart
class ConnectionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for connection state changes
    ref.listen(connectionStateProvider(device), (previous, next) {
      next.whenData((state) {
        if (state == BluetoothConnectionState.connected && 
            previous?.value != BluetoothConnectionState.connected) {
          // Auto-navigate to data screen on successful connection
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DataScreen(device: device)),
          );
        }
      });
    });

    return ElevatedButton(
      onPressed: () async {
        final isConnected = await ref.watch(connectionStateProvider(device).future);
        if (isConnected.name == 'connected') {
          ref.read(bleServiceProvider).disconnectFromDevice(device);
        } else {
          ref.read(bleServiceProvider).connectToDevice(device);
        }
      },
      child: ref.watch(connectionStateProvider(device)).when(
        data: (state) => Text(state.name == 'connected' ? 'Disconnect' : 'Connect'),
        loading: () => const Text('Connecting...'),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
```

**Advanced Patterns:**
- **Ref.listen()**: Side effects like navigation based on state changes
- **AsyncValue.when()**: Elegant handling of loading, success, and error states
- **Future Integration**: Converting streams to futures when needed

### 4. Live Data Visualization (`view_data_screen.dart`)

Real-time data display with automatic subscription management:

```dart
class ViewDataScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characteristicValue = ref.watch(characteristicValueProvider(characteristic));
    final connectionState = ref.watch(connectionStateProvider(device));

    return Scaffold(
      body: characteristicValue.when(
        data: (value) => Card(
          child: Column(
            children: [
              Text('Raw Data: ${utf8.decode(value)}'),
              Text('Hex: ${value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(', ')}'),
            ],
          ),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (error, _) => Text('Error: $error'),
      ),
    );
  }
}
```

## 🔄 BLE Workflow Explained

### 1. Device Discovery
```dart
// Start scanning
await bleService.startScan(timeout: Duration(seconds: 10));

// Listen to scan results
scanResultsProvider.stream.listen((devices) {
  // Update UI with discovered devices
});
```

### 2. Connection Process
```dart
// Initiate connection
await bleService.connectToDevice(device);

// Monitor connection state
connectionStateProvider(device).stream.listen((state) {
  if (state == BluetoothConnectionState.connected) {
    // Device connected - navigate to services
  }
});
```

### 3. Service Discovery
```dart
// Discover services after connection
final services = await bleService.discoverServices(device);

// Filter for notification-capable characteristics
final notifyCharacteristics = services
    .expand((service) => service.characteristics)
    .where((char) => char.properties.notify);
```

### 4. Live Data Streaming
```dart
// Subscribe to notifications
await bleService.subscribeToCharacteristic(characteristic);

// Stream updates automatically trigger UI rebuilds
characteristicValueProvider(characteristic).stream.listen((value) {
  // Raw bytes received from BLE device
  final stringData = utf8.decode(value);
  final hexData = value.map((b) => b.toRadixString(16)).join(' ');
});
```

## 🎯 Best Practices Demonstrated

### 1. **Error Handling**
- Comprehensive try-catch blocks in service layer
- User-friendly error messages via SnackBar
- Graceful degradation when BLE operations fail

### 2. **Memory Management**
- Automatic subscription cleanup
- Proper stream disposal
- Connection state monitoring to prevent leaks

### 3. **User Experience**
- Loading states for all async operations
- Visual connection indicators
- Automatic navigation on successful connection
- Real-time updates without manual refresh

### 4. **Code Organization**
- Separation of concerns between UI and business logic
- Reusable components and services
- Clean provider structure for state management

## 🚦 Common BLE Patterns

### Scanning with Filters
```dart
await bleService.startScan(
  withServices: [Guid("your-service-uuid")],
  filterByDeviceName: ["YourDevice"],
  timeout: Duration(seconds: 15),
);
```

### Reading Characteristics
```dart
final value = await bleService.readCharacteristic(characteristic);
```

### Writing to Characteristics
```dart
final data = utf8.encode("Hello BLE!");
await bleService.writeCharacteristic(characteristic, data);
```

### Notification Subscription
```dart
await bleService.subscribeToCharacteristic(characteristic);
bleService.characteristicValue(characteristic).listen((value) {
  print("Received: ${utf8.decode(value)}");
});
```

## 🔧 Customization Guide

### Adding Custom Device Filters
Modify the scanning parameters in `scan_screen.dart`:

```dart
bleService.startScan(
  withServices: [Guid("12345678-1234-1234-1234-123456789abc")],
  filterByDeviceName: ["MyDevice", "MyOtherDevice"],
);
```

### Custom Data Processing
Extend `view_data_screen.dart` with your data parsing logic:

```dart
int processTwoByteHexToDecimalSignedValue(int x, int y, List<int> valueArray) {
  return int.parse(
    (valueArray[x] << 8 | valueArray[y]).toRadixString(16),
    radix: 16,
  ).toSigned(16);
}
```

### Adding New Screens
Follow the established pattern:
1. Create the screen widget
2. Add necessary providers in `bluetooth_provider.dart`
3. Implement navigation in connection button or service screen

## 📱 Platform Considerations

### Android
- Requires location permissions for BLE scanning
- Different behavior on Android 12+ (BLUETOOTH_SCAN permission)
- Scanning modes affect battery usage and discovery speed

### iOS
- Background usage requires additional entitlements
- Core Bluetooth usage description required
- Different MTU negotiation behavior

## 🔍 Troubleshooting

### Common Issues

1. **Devices not found during scan**
   - Check permissions are granted
   - Ensure Bluetooth is enabled
   - Verify device is advertising

2. **Connection failures**
   - Check device is in range
   - Verify device isn't connected to another app
   - Try increasing connection timeout

3. **Notification not working**
   - Ensure characteristic supports notifications
   - Check if subscription was successful
   - Verify device is sending data

### Debug Tips
- Enable verbose logging in BLE service
- Use platform-specific BLE debugging tools
- Monitor connection state changes

## 📚 Learning Resources

- [FlutterBluePlus Documentation](https://pub.dev/packages/flutter_blue_plus)
- [Riverpod Documentation](https://riverpod.dev/)
- [Bluetooth Low Energy Specifications](https://www.bluetooth.com/specifications/bluetooth-core-specification/)

## 🤝 Contributing

This is an educational project. Feel free to:
- Report issues
- Suggest improvements
- Add new features
- Improve documentation

---

**Built with ❤️ by Lovely using Flutter, FlutterBluePlus, and Riverpod**

*This README serves as both documentation and educational content for developers learning BLE development in Flutter.*