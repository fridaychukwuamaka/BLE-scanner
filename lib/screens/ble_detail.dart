import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

final BleManager ble = BleManager();

class BLEDetail extends StatefulWidget {
  final ScanResult device;

  const BLEDetail({this.device});

  @override
  _BLEDetailState createState() => _BLEDetailState();
}

class _BLEDetailState extends State<BLEDetail> {
  ScanResult device;
  @override
  void initState() {
    initalize();
    super.initState();
  }

  initalize() {
    setState(() {
      device = widget.device;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.peripheral.name == '' ||
                widget.device.peripheral.name == null
            ? 'Unknown'
            : "${widget.device.peripheral.name}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<ScanResult>(
          initialData: device,
          stream: ble.startPeripheralScan(scanMode: ScanMode.lowLatency),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              final ScanResult peripheral = snapshot.data;
              if (peripheral.peripheral.identifier ==
                  device.peripheral.identifier) {
                device = snapshot.data;
              } else {
                // Navigator.pop(context);
              }
              return Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  spTile(
                    name: 'Level:',
                    value: '${device.rssi.toString()}dBm',
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  spTile(
                    name: 'Name:',
                    value: device.peripheral.name == '' ||
                            device?.peripheral?.name == null
                        ? 'Unknown'
                        : "${device.peripheral.name}",
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  spTile(
                    name: 'Address:',
                    value: device.peripheral.identifier ?? 'Unknown',
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              );
            } else {
              return Center(
                child: Text('Loading'),
              );
            }
          },
        ),
      ),
    );
  }

  Row spTile({
    String name,
    String value,
  }) {
    return Row(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
