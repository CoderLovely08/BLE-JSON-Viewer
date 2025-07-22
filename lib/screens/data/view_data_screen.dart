import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ble/bluetooth_provider.dart';

int processTwoByteHexToDecimalSignedValue(int x, int y, List<int> valueArray) {
  // Combine two bytes from the valueArray and convert to signed decimal
  return int.parse(
    (valueArray[x] << 8 | valueArray[y]).toRadixString(16),
    radix: 16,
  ).toSigned(16);
}

class ViewDataScreen extends ConsumerWidget {
  final BluetoothCharacteristic characteristic;
  final BluetoothDevice device;

  const ViewDataScreen({
    super.key,
    required this.characteristic,
    required this.device,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characteristicValue =
        ref.watch(characteristicValueProvider(characteristic));
    final connectionState = ref.watch(connectionStateProvider(device));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Characteristic Data'),
        actions: [
          connectionState.when(
            data: (state) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.bluetooth_connected,
                color: state == BluetoothConnectionState.connected
                    ? Colors.blue
                    : Colors.red,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Icon(
              Icons.bluetooth_disabled,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UUID: ${characteristic.uuid}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Properties:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('Read: ${characteristic.properties.read}'),
                Text('Write: ${characteristic.properties.write}'),
                Text('Notify: ${characteristic.properties.notify}'),
                const Divider(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest Value:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (characteristic.properties.read)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            ref
                                .read(bleServiceProvider)
                                .readCharacteristic(characteristic);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  characteristicValue.when(
                    data: (value) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Raw Data: ${utf8.decode(value)}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              'Hex: ${value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(', ')}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error: $error'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
