import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  
  factory BluetoothService() => _instance;
  
  BluetoothService._internal();
  
  final StorageService _storageService = StorageService();
  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _writeCharacteristic;
  
  final ValueNotifier<String> connectionStatus = ValueNotifier<String>('Desconectado');
  
  bool get isConnected => _connectedDevice != null && _writeCharacteristic != null;
  
  Future<bool> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });
    
    return allGranted;
  }
  
  Future<bool> connectToDevice() async {
    final targetMac = await _storageService.getMacAddress();
    if (targetMac == null) {
      connectionStatus.value = 'Endereço MAC não configurado';
      return false;
    }

    connectionStatus.value = 'Procurando dispositivo...';
    
    try {
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      bool deviceFound = false;
      
      await for (final result in fbp.FlutterBluePlus.scanResults) {
        for (fbp.ScanResult r in result) {
          if (r.device.remoteId.toString().toUpperCase() == targetMac.toUpperCase()) {
            await fbp.FlutterBluePlus.stopScan();
            
            connectionStatus.value = 'Dispositivo encontrado, conectando...';
            
            await r.device.connect();
            
            // Descobrir serviços e características
            List<fbp.BluetoothService> services = await r.device.discoverServices();
            for (fbp.BluetoothService service in services) {
              for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
                if (characteristic.properties.write) {
                  _writeCharacteristic = characteristic;
                  break;
                }
              }
            }
            
            _connectedDevice = r.device;
            connectionStatus.value = 'Conectado a ${r.device.remoteId}';
            deviceFound = true;
            break;
          }
        }
        
        if (deviceFound) break;
      }
      
      if (!deviceFound) {
        connectionStatus.value = 'Dispositivo não encontrado';
        return false;
      }
      
      return isConnected;
    } catch (e) {
      connectionStatus.value = 'Erro: $e';
      return false;
    }
  }
  
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _writeCharacteristic = null;
        connectionStatus.value = 'Desconectado';
      }
    } catch (e) {
      connectionStatus.value = 'Erro ao desconectar: $e';
    }
  }
  
  Future<bool> sendCommand(String command) async {
    if (_writeCharacteristic != null) {
      try {
        await _writeCharacteristic!.write(command.codeUnits);
        connectionStatus.value = 'Comando enviado: $command';
        return true;
      } catch (e) {
        connectionStatus.value = 'Erro ao enviar comando: $e';
        return false;
      }
    } else {
      connectionStatus.value = 'Característica de escrita não encontrada';
      return false;
    }
  }
} 