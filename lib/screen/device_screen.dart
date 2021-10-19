import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectedDeviceScreen extends StatelessWidget {
  final BluetoothDevice device;
  const ConnectedDeviceScreen({Key? key, required this.device})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [_getActionBarMenu()],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: StreamBuilder<List<BluetoothService>>(
            initialData: const [],
            stream: device.services,
            builder: (c, snapshot) {
              return Column(
                children: snapshot.data!.map((d) => _buildItem(d)).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getActionBarMenu() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: StreamBuilder<BluetoothDeviceState>(
          initialData: BluetoothDeviceState.connecting,
          stream: device.state,
          builder: (c, snapshot) {
            String title = '';
            VoidCallback? action;
            switch (snapshot.data) {
              case BluetoothDeviceState.connecting:
                title = 'CONNECTING';
                action = null;
                break;

              case BluetoothDeviceState.connected:
                title = 'DISCONNECT';
                device.discoverServices();
                action = () {
                  device.disconnect();
                };
                break;

              case BluetoothDeviceState.disconnected:
                title = 'CONNECT';
                action = () {
                  device.connect();
                };
                break;
            }

            return InkWell(
              child: Text(title),
              onTap: action,
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(BluetoothService service) {
    return ExpansionTile(
      title: const Text(
        'Service',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Expanded(
        child: Text(
          service.uuid.toString(),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      children: service.characteristics
          .map((e) => _buildCharacteristicRow(e))
          .toList(),
    );
  }

  Widget _buildCharacteristicRow(BluetoothCharacteristic characteristic) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Characteristic UUID: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(child: Text(characteristic.uuid.toString())),
            ],
          ),
          _buildCharactericticProperties(characteristic.properties)
        ],
      ),
    );
  }

  Widget _buildCharactericticProperties(CharacteristicProperties properties) {
    String propertiesString = '';
    if (properties.read) {
      propertiesString += 'R';
    }

    if (properties.write) {
      propertiesString += 'W';
    }

    if (properties.notify) {
      propertiesString += 'N';
    }

    return Row(
      children: [
        const Text(
          'Properties: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          propertiesString,
        ),
      ],
    );
  }
}
