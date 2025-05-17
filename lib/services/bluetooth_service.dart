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

  // Controle do estado
  final ValueNotifier<String> connectionStatus = ValueNotifier<String>('Desconectado');
  final ValueNotifier<List<fbp.ScanResult>> scanResults = ValueNotifier<List<fbp.ScanResult>>([]);
  final ValueNotifier<bool> isScanning = ValueNotifier<bool>(false);

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

    connectionStatus.value = 'Conectando...';

    try {
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      bool deviceFound = false;

      await for (final result in fbp.FlutterBluePlus.scanResults) {
        for (fbp.ScanResult r in result) {
          if (r.device.remoteId.toString().toUpperCase() == targetMac.toUpperCase()) {
            await fbp.FlutterBluePlus.stopScan();

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
            connectionStatus.value = 'Conectado';
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
      connectionStatus.value = 'Erro na conexão';
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
      connectionStatus.value = 'Erro ao desconectar';
    }
  }

  Future<void> saveMacAddress(String macAddress) async {
    await _storageService.saveMacAddress(macAddress);
  }

  Future<bool> sendCommand(String command) async {
    if (_writeCharacteristic != null) {
      try {
        await _writeCharacteristic!.write(command.codeUnits);
        return true;
      } catch (e) {
        connectionStatus.value = 'Erro ao enviar comando';
        return false;
      }
    } else {
      connectionStatus.value = 'Desconectado';
      return false;
    }
  }

  // Método para escanear dispositivos BLE
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      // Limpar resultados anteriores
      scanResults.value = [];
      isScanning.value = true;
      connectionStatus.value = 'Escaneando dispositivos...';

      // Iniciar escaneamento
      await fbp.FlutterBluePlus.startScan(timeout: timeout);

      // Escutar resultados do escaneamento
      fbp.FlutterBluePlus.scanResults.listen((results) {
        List<fbp.ScanResult> uniqueResults = [];

        // Filtrar resultados duplicados
        for (fbp.ScanResult result in results) {
          if (!uniqueResults.any((r) => r.device.remoteId == result.device.remoteId)) {
            uniqueResults.add(result);
          }
        }

        scanResults.value = uniqueResults;
      });

      // Escutar estado do escaneamento
      fbp.FlutterBluePlus.isScanning.listen((scanning) {
        isScanning.value = scanning;
        if (!scanning) {
          connectionStatus.value = 'Escaneamento concluído. ${scanResults.value.length} dispositivos encontrados.';
        }
      });
    } catch (e) {
      isScanning.value = false;
      connectionStatus.value = 'Erro ao escanear: $e';
    }
  }

  Future<void> stopScan() async {
    try {
      await fbp.FlutterBluePlus.stopScan();
    } catch (e) {
      connectionStatus.value = 'Erro ao parar escaneamento: $e';
    }
  }

  // Método para conectar a um dispositivo específico a partir do resultado do escaneamento
  Future<bool> connectToScannedDevice(fbp.ScanResult result) async {
    try {
      connectionStatus.value = 'Conectando a ${result.device.remoteId}...';

      // Parar escaneamento antes de conectar
      await stopScan();

      // Conectar ao dispositivo
      await result.device.connect();

      // Descobrir serviços e características
      List<fbp.BluetoothService> services = await result.device.discoverServices();
      for (fbp.BluetoothService service in services) {
        for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            break;
          }
        }
      }

      _connectedDevice = result.device;
      connectionStatus.value = 'Conectado a ${result.device.remoteId}';

      // Salvar o endereço MAC para conexões futuras
      await _storageService.saveMacAddress(result.device.remoteId.toString());

      return isConnected;
    } catch (e) {
      connectionStatus.value = 'Erro ao conectar: $e';
      return false;
    }
  }
}