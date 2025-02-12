import 'package:ble_tester/screens/scan/widgets/connection_button.dart';
import 'package:ble_tester/utils/app.constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../providers/ble/bluetooth_provider.dart';

class BleTester extends ConsumerStatefulWidget {
  const BleTester({super.key});

  @override
  ConsumerState<BleTester> createState() => _BleTesterState();
}

class _BleTesterState extends ConsumerState<BleTester> {
  @override
  void initState() {
    super.initState();
    ref.read(bleServiceProvider).startScan();
  }

  @override
  Widget build(BuildContext context) {
    final scanResults = ref.watch(scanResultsProvider);
    final bluetoothState = ref.watch(bluetoothStateProvider);
    final isCurrentlyScanning = ref.watch(isScanning);
    final bleService = ref.watch(bleServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Tester'),
        actions: [
          bluetoothState.when(
            data: (state) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.bluetooth,
                color: state == BluetoothAdapterState.on
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) =>
                const Icon(Icons.bluetooth_disabled, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: scanResults.when(
              data: (devices) => ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].device;
                  return ListTile(
                    title: Text(device.advName.isEmpty
                        ? 'Unknown Device'
                        : device.advName),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: ConnectionButton(device: device),
                    onTap: () {},
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Scan'),
        onPressed: () {
          if (isCurrentlyScanning.value == true) {
            bleService.stopScan();
          } else {
            bleService.startScan();
          }
        },
        icon: isCurrentlyScanning.when(
          data: (scanning) => scanning
              ? SizedBox(
                  height: AppConstants.spinnerSize,
                  width: AppConstants.spinnerSize,
                  child: CircularProgressIndicator())
              : Icon(Icons.search),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
