import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'dart:io' show Platform;

import 'package:location_permissions/location_permissions.dart';
//import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Arduino Temperature'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  late StreamSubscription _subscription;
  late StreamSubscription<ConnectionStateUpdate> _connection;

  String boton = '';
  String temp = 'wait temperature';
  String hum = 'wait humidity';
  bool permGranted = false;

//bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;
// Bluetooth related variables
//late DiscoveredDevice _myDevice;
//late StreamSubscription<DiscoveredDevice> _scanStream;
//late QualifiedCharacteristic _rxCharacteristic;
// These are the UUIDs of your device
  final Uuid serviceUuid = Uuid.parse("ef680300-9b35-4933-9b10-52ffa9740042");
  final Uuid characteristicUuid =
      Uuid.parse("ef680302-9b35-4933-9B10-52ffa9740042");

  final Uuid serviceUuid2 = Uuid.parse("ef680200-9b35-4933-9b10-52ffa9740042");
  final Uuid characteristicUuid2 =
      Uuid.parse("ef680201-9b35-4933-9B10-52ffa9740042");

  final Uuid serviceUuid3 = Uuid.parse("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Uuid characteristicUuid3 =
      Uuid.parse("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  final Uuid characteristicUuidRX =
      Uuid.parse("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

  final Uuid serviceUuidXia =
      Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final Uuid characteristicUuidXia =
      Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  void _adPermission() async {
// Platform permissions handling stuff
    //bool permGranted = false;
    setState(() {
      _scanStarted = true;
    });
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) {
        setState(() {
          permGranted = true;
        });
      }
    } else if (Platform.isIOS) {
      permGranted = true;
    }
// Main scanning logic happens here ⤵
    if (permGranted) {
      print('permitido');
      // _scanStream =
      /* _ble.scanForDevices(withServices: []).listen((device) {
        // Change this string to what you defined in Zephyr
        if (device.name == 'Thin') {
          print('encontrado ${device.id}');
          setState(() {
            //_myDevice = device;
            // _foundDeviceWaitingToConnect = true;
            return;
          });
        }
      });*/
    }
  }

  void _disconnect() async {
    _subscription.cancel();
    if (_connection != null) {
      await _connection.cancel();
    }
  }

  void _connectBLE() {
    _adPermission();
    String ID = "F1:4F:0A:B4:7E:B3";
    String IDM5 = "08:3A:F2:65:F5:BE";
    String ID2 = "30:AE:A4:28:39:36";

    if (permGranted) {
      //_startScan();

      //_scanStream.cancel();
      // _disconnect();
      String response = '';
      //_startScan();

      var mi=_ble
          .connectToAdvertisingDevice(
              id: IDM5,
              //_myDevice.id,
              withServices: [],
              prescanDuration: Duration(seconds: 4))
          .listen((connectionState) {
        
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          print('conectado ${ID}');
          final characteristic = QualifiedCharacteristic(
              serviceId: serviceUuid,
              characteristicId: characteristicUuid,
              deviceId: ID
              //_myDevice.id
              );

          final characteristic2 = QualifiedCharacteristic(
              serviceId: serviceUuid2,
              characteristicId: characteristicUuid2,
              deviceId: ID
              //_myDevice.id
              );

          final characteristic3 = QualifiedCharacteristic(
              serviceId: serviceUuid3,
              characteristicId: characteristicUuid3,
              deviceId: IDM5
              //_myDevice.id
              );

          final characteristicRX = QualifiedCharacteristic(
              serviceId: serviceUuid3,
              characteristicId: characteristicUuidRX,
              deviceId: IDM5
              //_myDevice.id
              );
          final characteristicXia = QualifiedCharacteristic(
              serviceId: serviceUuidXia,
              characteristicId: characteristicUuidXia,
              deviceId: ID2
              // "A4:C1:38:7A:AC:CD"
              //_myDevice.id
              );

          print('estatus ${_ble.status}');

          /*_ble.subscribeToCharacteristic(characteristic).listen((event) {
            print('dato ${event.toString()}');
            setState(() {
              boton = event[0].toString();
            });
          }, onError: (error) {
            print('lacagada ${error.toString()}');
          });*/
          /* _ble.writeCharacteristicWithoutResponse(characteristicRX,
              value: [104, 111, 110, 97]);*/

          _ble.subscribeToCharacteristic(characteristic3).listen((event) {
            print('temp ${event.toString()}');
            setState(() {
              var utf = Utf8Decoder();
              temp = utf.convert(event.toList());
              //temp = event.toString();
            });
          }, onError: (error) {
            print('lacagada ${error.toString()}');
          });
          print('disconnected');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xffffdf6f), Color(0xffeb2d95)])),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              permGranted ? Text('Permiso dado') : Text('Activar permisos'),
              Text(boton),
              Text('temperature $temp')
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connectBLE,
        tooltip: 'Increment',
        backgroundColor: Color(0xFF74A4BC),
        child: Icon(Icons.loop),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
