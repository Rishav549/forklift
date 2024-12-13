import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../components/device.dart';
import 'deviceScreen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    FlutterBluePlus.startScan();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Devices"),
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.scanResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }
          return ListView(
            children: [
              if (snapshot.hasData && snapshot.data != null)
                ...snapshot.data!
                    .where((element) => element.device.platformName.isNotEmpty)
                    .map((e) => SystemDeviceTile(
                        device: e.device,
                        onOpen: () async {
                          if (context.mounted)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DeviceDetailsScreen(device: e.device)));
                        },
                        onConnect: () {
                          e.device.connect();
                        }))
            ],
          );
        },
      ),
    );
  }
}
