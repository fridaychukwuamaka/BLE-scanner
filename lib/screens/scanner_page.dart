import 'dart:async';
import 'dart:io';
import 'package:ble_scanner/screens/ble_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

import 'package:location_permissions/location_permissions.dart';

BleManager ble = BleManager();

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<ScanResult> devices = [];

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    //Initializing the library
    await ble.createClient();

    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) {
        Timer(Duration(minutes: 2), () {
          ble.stopPeripheralScan();
          ble.disableRadio();
        });
      }
    } else if (Platform.isIOS) {}
  }

  refreshDevices() async {
    //Clear array
    devices = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner page'),
      ),
      body: StreamBuilder<ScanResult>(
        stream: ble.startPeripheralScan(scanMode: ScanMode.lowLatency),
        builder: (context, snapshot) {
          BluetoothState bluetoothStatus;
          final ScanResult peripheral = snapshot.data;
          print('gfjkfg');
          ble.bluetoothState().then((value) {
            bluetoothStatus = value;
            print(bluetoothStatus);
          });
          if (snapshot.hasData) {
            // print(snapshot.data.peripheral.identifier);
            if (devices.isNotEmpty) {
              //Checks if the device ia already in the list
              var oldDevice = devices.indexWhere((element) =>
                  element?.peripheral?.identifier ==
                  peripheral?.peripheral?.identifier);
              if (oldDevice == -1) {
                //If device doesn't exist on the list then add the device to the list
                devices.add(snapshot.data);
              } else {
                //If the device is in the list update the device data
                devices[oldDevice] = snapshot.data;
              }
            } else {
              devices.add(snapshot.data);
            }
            return ListView.builder(
                itemCount: devices?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              BLEDetail(device: devices[index]),
                        ),
                      );
                      setState(() {
                        print(devices);
                      });
                    },
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${devices[index].rssi.toString()}dBm'),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                    ),
                    title: Text(
                      devices[index].peripheral?.name == '' ||
                              devices[index]?.peripheral?.name == null
                          ? 'Unknown'
                          : "${devices[index]?.peripheral?.name}",
                    ),
                    subtitle: Text(
                        "${devices[index]?.peripheral?.identifier}" ??
                            'Unknown'),
                  );
                });
          } else if (!snapshot.hasData) {
            return Center(
              child: Text('Scanning'),
            );
          } else if (devices.length == 0) {
            return Center(child: Text('No device Seen'));
          } else {
            return Center(
              child: Text('Error'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshDevices,
        child: Icon(
          Icons.refresh_rounded,
        ),
      ),
    );
  }
}
