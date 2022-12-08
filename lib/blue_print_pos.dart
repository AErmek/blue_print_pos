import 'dart:io';

import 'package:blue_print_pos/models/models.dart';
import 'package:blue_print_pos/scanner/blue_scanner.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue_thermal;
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue;
import 'package:flutter_blue_plus/gen/flutterblueplus.pb.dart' as proto;

class BluePrintPos {
  BluePrintPos._() {
    _bluetoothAndroid = blue_thermal.BlueThermalPrinter.instance;
    _bluetoothIOS = flutter_blue.FlutterBluePlus.instance;
  }

  static BluePrintPos get instance => BluePrintPos._();

  /// This field is library to handle in Android Platform
  blue_thermal.BlueThermalPrinter? _bluetoothAndroid;

  /// This field is library to handle in iOS Platform
  flutter_blue.FlutterBluePlus? _bluetoothIOS;

  /// Bluetooth Device model for iOS
  flutter_blue.BluetoothDevice? _bluetoothDeviceIOS;

  /// State to get bluetooth is connected
  bool _isConnected = false;

  /// Getter value [_isConnected]
  bool get isConnected => _isConnected;

  /// Selected device after connecting
  BlueDevice? selectedDevice;

  /// return bluetooth device list, handler Android and iOS in [BlueScanner]
  Future<List<BlueDevice>> scan() async {
    return await BlueScanner.scan();
  }

  /// When connecting, reassign value [selectedDevice] from parameter [device]
  /// and if connection time more than [timeout]
  /// will return [ConnectionStatus.timeout]
  /// When connection success, will return [ConnectionStatus.connected]
  Future<ConnectionStatus> connect(
    BlueDevice device, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    selectedDevice = device;
    try {
      if (Platform.isAndroid) {
        final blue_thermal.BluetoothDevice bluetoothDeviceAndroid =
            blue_thermal.BluetoothDevice(
                selectedDevice?.name ?? '', selectedDevice?.address ?? '');
        await _bluetoothAndroid?.connect(bluetoothDeviceAndroid);
      } else if (Platform.isIOS) {
        _bluetoothDeviceIOS = flutter_blue.BluetoothDevice.fromProto(
          proto.BluetoothDevice(
            name: selectedDevice?.name ?? '',
            remoteId: selectedDevice?.address ?? '',
            type: proto.BluetoothDevice_Type.valueOf(selectedDevice?.type ?? 0),
          ),
        );
        final List<flutter_blue.BluetoothDevice> connectedDevices =
            await _bluetoothIOS?.connectedDevices ??
                <flutter_blue.BluetoothDevice>[];
        final int deviceConnectedIndex = connectedDevices
            .indexWhere((flutter_blue.BluetoothDevice bluetoothDevice) {
          return bluetoothDevice.id == _bluetoothDeviceIOS?.id;
        });
        if (deviceConnectedIndex < 0) {
          await _bluetoothDeviceIOS?.connect(timeout: timeout);
        }
      }

      _isConnected = true;
      return ConnectionStatus.connected;
    } on Exception catch (error) {
      print('connect: $runtimeType - Error $error');
      final String errorText = error.toString();

      if (errorText.contains('already connected')) {
        _isConnected = true;
        return ConnectionStatus.connected;
      }

      _isConnected = false;
      return ConnectionStatus.timeout;
    }
  }

  /// To stop communication between bluetooth device and application
  Future<ConnectionStatus> disconnect({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      if (Platform.isAndroid) {
        await _bluetoothAndroid?.disconnect();
        _isConnected = false;
      } else if (Platform.isIOS) {
        await _bluetoothDeviceIOS?.disconnect();
        _isConnected = false;
      }
    } on Exception catch (error) {
      print('disconnect: $runtimeType - Error $error');
    }

    return ConnectionStatus.disconnect;
  }

  /// public write buffer method
  Future<void> writeBuffer(List<int> byteBuffer) async {
    try {
      if (selectedDevice == null) {
        print('$runtimeType - Device not selected');
        return Future<void>.value(null);
      }
      if (!_isConnected && selectedDevice != null) {
        await connect(selectedDevice!);
      }
      if (Platform.isAndroid) {
        _bluetoothAndroid?.writeBytes(Uint8List.fromList(byteBuffer));
      } else if (Platform.isIOS) {
        final List<flutter_blue.BluetoothService> bluetoothServices =
            await _bluetoothDeviceIOS?.discoverServices() ??
                <flutter_blue.BluetoothService>[];
        final flutter_blue.BluetoothService bluetoothService =
            bluetoothServices.firstWhere(
          (flutter_blue.BluetoothService service) => service.isPrimary,
        );
        final flutter_blue.BluetoothCharacteristic characteristic =
            bluetoothService.characteristics.firstWhere(
          (flutter_blue.BluetoothCharacteristic bluetoothCharacteristic) =>
              bluetoothCharacteristic.properties.write,
        );
        await characteristic.write(byteBuffer, withoutResponse: true);
      }
    } on Exception catch (error) {
      print('$runtimeType - Error $error');
    }
  }

  Future<bool?> get isOn async {
    if (Platform.isAndroid) {
      return await _bluetoothAndroid?.isOn;
    } else if (Platform.isIOS) {
      return await _bluetoothIOS?.isOn;
    }

    throw UnsupportedError('Unsupported platform');
  }
}
