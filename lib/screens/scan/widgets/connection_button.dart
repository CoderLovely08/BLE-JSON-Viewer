import 'package:ble_tester/providers/ble/bluetooth_provider.dart';
import 'package:ble_tester/screens/data/services_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionButton extends ConsumerWidget {
  const ConnectionButton({super.key, required this.device});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(connectionStateProvider(device), (previous, next) {
      next.whenData((state) {
        if (state == BluetoothConnectionState.connected && 
            previous?.value != BluetoothConnectionState.connected) {
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DataScreen(device: device),
              ),
            );
          }
        }
      });
    });

    return ElevatedButton(
      onPressed: () async {
        final isConnected =
            await ref.watch(connectionStateProvider(device).future);
        if (isConnected.name == 'connected') {
          ref.read(bleServiceProvider).disconnectFromDevice(device);
        } else {
          ref.read(bleServiceProvider).connectToDevice(device);
        }
      },
      child: ref.watch(connectionStateProvider(device)).when(
            data: (state) =>
                Text(state.name == 'connected' ? 'Disconnect' : 'Connect'),
            loading: () => const Text('Connecting...'),
            error: (error, stack) => Text('Error: $error'),
          ),
    );
  }
}
