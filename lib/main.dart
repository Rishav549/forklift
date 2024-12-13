import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:forklift/routes/deviceListScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X-Monitor',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: const MaterialColor(0xff0a8f77,  <int, Color>{
          50: Color(0xff0a8f77),
          100: Color(0xff0a8f77),
          200: Color(0xff0a8f77),
          300: Color(0xff0a8f77),
          400: Color(0xff0a8f77),
          500: Color(0xff0a8f77),
          600: Color(0xff0a8f77),
          700: Color(0xff0a8f77),
          800: Color(0xff0a8f77),
          900: Color(0xff0a8f77),
        }),
        primaryColor: const Color(0xff0a8f77),
        scaffoldBackgroundColor: Colors.black45,
      ),
      home: const MyHomePage(title: 'X-Monitor'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: StreamBuilder(
        stream: FlutterBluePlus.adapterState,
        builder: (context, snapshot) {
          if(snapshot.data == BluetoothAdapterState.off){
            return Container(
              alignment: Alignment.center,
              child:const Text("Please Turn bluetooth ON"),
            );
          }
          else if(snapshot.data == BluetoothAdapterState.on){
            return const DeviceListScreen();
          }
          return Container(alignment: Alignment.center,child: const CircularProgressIndicator(),);
        },),
    );
  }
}