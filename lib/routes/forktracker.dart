import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:forklift/utilities/logger.dart';

import '../model/Gyromodel.dart';

class ForkTracker extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final BluetoothDevice device;

  const ForkTracker(
      {super.key, required this.characteristic, required this.device});

  @override
  State<ForkTracker> createState() => _ForkTrackerState();
}

class _ForkTrackerState extends State<ForkTracker> {
  late StreamSubscription _subscription;
  late BluetoothCharacteristic characteristic;
  double altitude = 0.0;
  double initialAltitude = 0.0;
  double deviation = 0.0, initialDeviation = 0.0;
  Color onContainerColor = Colors.red;

  @override
  void initState() {
    super.initState();
    readData();
  }

  void readData() async {
    characteristic = widget.characteristic;
    await widget.characteristic.setNotifyValue(true);
    _subscription = characteristic.onValueReceived.listen((event) {
      List<String> data = String.fromCharCodes(event).split(",");

      GyroModel modelData = GyroModel(
          p: double.parse(data[0]),
          t: double.parse(data[1]),
          x: double.parse(data[2]),
          y: double.parse(data[3]),
          z: double.parse(data[4]));
      setState(() {
        altitude = (288.15 / 0.0065) *
            (1 -
                pow(modelData.p / 101325,
                    (287.05 * 0.0065) / (9.80665 * 287.05)));
        initialDeviation = sqrt((pow(modelData.x, 2)) +
            (pow(modelData.y, 2)) +
            (pow(modelData.z, 2)));
        if (initialDeviation / 10 > 1.1) {
          onContainerColor = Colors.green;
        }
      });
    });
  }

  void resetAltitude() {
    setState(() {
      initialAltitude = altitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double minAltitude = 0.0;
    const double maxAltitude = 100.0;
    const double minPosition = 450.0;
    const double maxPosition = 200.0;

    double lifterVerticalPosition =
        (initialDeviation / 10 > 0.9 || initialDeviation / 10 < 0.9)
            ? minPosition -
                (((altitude - initialAltitude) * 100000)
                        .clamp(minAltitude, maxAltitude) /
                    (maxAltitude - minAltitude) *
                    (minPosition - maxPosition))
            : minPosition -
                (((initialAltitude - initialAltitude) * 100000)
                        .clamp(minAltitude, maxAltitude) /
                    (maxAltitude - minAltitude) *
                    (minPosition - maxPosition));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                "asset/images/title.png",
                width: 200,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  color: onContainerColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 84,
                height: 39,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "On",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Image.asset(
                      "asset/images/Vector.png",
                      width: 13.33,
                      height: 13.33,
                    )
                  ],
                ),
              ),
            ),
          ),
          Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1000),
                top: lifterVerticalPosition,
                left: 8,
                child: Image.asset(
                  "asset/images/lifter.png",
                  width: 160,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  "asset/images/truck.png",
                  width: 198,
                  height: 521,
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(color: Colors.black.withOpacity(0.1)),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (altitude - initialAltitude).toStringAsFixed(6),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 21),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0084FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16.5),
                            ),
                            onPressed: resetAltitude,
                            child: const Text(
                              "Zero",
                              style: TextStyle(color: Colors.white),
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
