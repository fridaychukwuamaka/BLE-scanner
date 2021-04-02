import 'dart:ui';
import 'package:ble_scanner/screens/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BLEDetail extends StatefulWidget {
  final DiscoveredDevice device;

  const BLEDetail({this.device});

  @override
  _BLEDetailState createState() => _BLEDetailState();
}

class _BLEDetailState extends State<BLEDetail> {
  DiscoveredDevice device;
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
        title: Text(widget.device.name == '' || widget.device.name == null
            ? 'Unknown'
            : "${widget.device.name}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DiscoveredDevice>(
          initialData: device,
          stream: ble.scanForDevices(
            withServices: [],
            scanMode: ScanMode.balanced,
          ),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.id == device.id) {
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
                    value: device.name == '' || device?.name == null
                        ? 'Unknown'
                        : "${device?.name}",
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  spTile(
                    name: 'Address:',
                    value: device.id ?? 'Unknown',
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
