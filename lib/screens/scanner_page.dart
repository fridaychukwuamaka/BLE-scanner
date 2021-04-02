import 'dart:async';
import 'dart:io';
import 'package:ble_scanner/screens/ble_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:system_shortcuts/system_shortcuts.dart';

final ble = FlutterReactiveBle();


class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<DiscoveredDevice> devices = [];

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    //Initializing the library
    await ble.initialize();

    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) {
        Timer(Duration(seconds: 10), () {
          print('ready');
          if (ble.status == BleStatus.ready) {
            SystemShortcuts.bluetooth();
          }
        });
      }
    } else if (Platform.isIOS) {}
  }

  searchForDevices() async {
    setState(()  {
      //Clear array
      devices = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner page'),
      ),
      body: StreamBuilder<DiscoveredDevice>(
        stream: ble.scanForDevices(
          withServices: [],
          scanMode: ScanMode.balanced,
        ),
        builder: (context, snapshot) {
        
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            if (devices.isNotEmpty) {
              //Checks if the device ia already in the list
              var oldDevice = devices
                  .indexWhere((element) => element?.id == snapshot?.data?.id);
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
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${devices[index].rssi.toString()}dBm'),
                      ],
                    ),
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
                    trailing: Icon(
                      Icons.chevron_right,
                    ),
                    title: Text(
                      devices[index].name == '' || devices[index]?.name == null
                          ? 'Unknown'
                          : "${devices[index]?.name}",
                    ),
                    subtitle: Text("${devices[index]?.id}" ?? 'Unknown'),
                  );
                });
          }
         else if (
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text('Scanning'),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Bluetooth disabled'),
            );
          } else {
            return Center(
              child: Text('Try agian'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: searchForDevices,
        child: Icon(
          Icons.refresh_rounded,
        ),
      ),
    );
  }
}
