import 'package:bluetooth_demo/provider/search_devices_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'device_screen.dart';

class SearchDevicesWidget extends StatelessWidget {
  const SearchDevicesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start search",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [_getAppBarMenu(context)],
      ),
      body: _buildBody(context),
    );
  }

  Widget _getAppBarMenu(BuildContext context) {
    final provider = Provider.of<SearchDevicesProvider>(context);
    return StreamBuilder<bool>(
      stream: provider.getScanningStateStream(),
      initialData: false,
      builder: (c, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: InkWell(
            child: Icon(
              snapshot.data! ? Icons.close : Icons.refresh,
            ),
            onTap: () {
              if (snapshot.data!) {
                provider.stopSearch();
              } else {
                provider.startSearch();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final provider = Provider.of<SearchDevicesProvider>(context);
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<bool>(
              initialData: false,
              stream: provider.getScanningStateStream(),
              builder: (c, snapshot) {
                return snapshot.data!
                    ? Container(
                        padding: const EdgeInsets.only(bottom: 15),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      )
                    : Container();
              },
            ),
            StreamBuilder<List<ScanResult>>(
              initialData: const [],
              stream: provider.getScanResultStream(),
              builder: (c, snapshot) {
                return Column(
                  children: snapshot.data!
                      .map((d) => _buildDeviceItem(context, d))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, ScanResult result) {
    return ExpansionTile(
      collapsedBackgroundColor:
          result.advertisementData.connectable ? Colors.white : Colors.grey,
      backgroundColor:
          result.advertisementData.connectable ? Colors.white : Colors.grey,
      title: Text(
        result.device.name.isNotEmpty
            ? result.device.name
            : result.device.id.toString(),
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        child: const Text("Connect"),
        onPressed: result.advertisementData.connectable
            ? () {
                _showConnectConfirmationDialog(context, result);
              }
            : null,
      ),
      children: [
        _buildRow('Complete Local Name', result.advertisementData.localName),
        _buildRow('Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildRow('Manufacturer Data',
            getNiceManufacturerData(result.advertisementData.manufacturerData)),
        _buildRow(
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildRow('Service Data',
            getNiceServiceData(result.advertisementData.serviceData))
      ],
    );
  }

  Widget _buildRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
            ),
          )
        ],
      ),
    );
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  Future<void> _showConnectConfirmationDialog(
      BuildContext context, ScanResult scanResult) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm connection"),
            content: Text(
                'Do you want to connect to ${scanResult.device.name.isNotEmpty ? scanResult.device.name : scanResult.device.id.toString()}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  _showConnectingDialog(context, scanResult);
                  scanResult.device.connect();
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ConnectedDeviceScreen(device: scanResult.device,);
                  }));
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> _showConnectingDialog(
      BuildContext context, ScanResult scanResult) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Connecting"),
              content: Container(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ));
        });
  }
}
