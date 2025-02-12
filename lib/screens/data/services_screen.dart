import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ble/bluetooth_provider.dart';
import '../../widgets/common/custom_snack_bar.dart';
import '../../screens/data/view_data_screen.dart';

class DataScreen extends ConsumerStatefulWidget {
  final BluetoothDevice device;

  const DataScreen({super.key, required this.device});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  List<BluetoothService>? services;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  Future<void> _discoverServices() async {
    try {
      final discoveredServices =
          await ref.read(bleServiceProvider).discoverServices(widget.device);
      if (mounted) {
        setState(() {
          services = discoveredServices;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError('Failed to discover services: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.advName),
        actions: [
          ref.watch(connectionStateProvider(widget.device)).when(
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : services == null
              ? const Center(child: Text('No services found'))
              : ListView.builder(
                  itemCount: services!.length,
                  itemBuilder: (context, serviceIndex) {
                    final service = services![serviceIndex];
                    return service.characteristics.any((characteristic) =>
                            characteristic.properties.notify)
                        ? ExpansionTile(
                            title: Text('Service: ${service.uuid}'),
                            children: service.characteristics.map(
                              (characteristic) {
                                return characteristic.properties.notify
                                    ? ListTile(
                                        title: Text(
                                            'Characteristic: ${characteristic.uuid}'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Notify: ${characteristic.properties.notify}'),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (characteristic.properties.read)
                                              IconButton(
                                                icon: const Icon(Icons.refresh),
                                                onPressed: () async {
                                                  try {
                                                    final value = await ref
                                                        .read(
                                                            bleServiceProvider)
                                                        .readCharacteristic(
                                                            characteristic);
                                                    if (mounted) {
                                                      CustomSnackbar
                                                          .showSuccess(
                                                              'Value: $value');
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      CustomSnackbar.showError(
                                                          'Failed to read: $e');
                                                    }
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                        onTap: () {
                                          ref
                                              .read(bleServiceProvider)
                                              .subscribeToCharacteristic(
                                                  characteristic);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewDataScreen(
                                                characteristic: characteristic,
                                                device: widget.device,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox.shrink();
                              },
                            ).toList(),
                          )
                        : const SizedBox.shrink();
                  },
                ),
    );
  }
}
