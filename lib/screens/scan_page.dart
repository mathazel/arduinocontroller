import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bluetooth_page.dart';
import 'mac_config_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isBluetoothReady = false;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  @override
  void dispose() {
    _scanResultsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeBluetooth() async {
    await _requestPermissions();
    
    if (await FlutterBluePlus.isAvailable == false) {
      debugPrint('Bluetooth não está disponível neste dispositivo');
      return;
    }

    // Configure o listener de resultados de escaneamento logo no início
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    }, onError: (e) {
      debugPrint('Erro no listener de escaneamento: $e');
    });

    // Verifica se o bluetooth está ligado
    if (await FlutterBluePlus.isOn == false) {
      debugPrint('Bluetooth está desativado');
      return;
    }

    setState(() {
      _isBluetoothReady = true;
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  Future<void> _startScan() async {
    if (!_isBluetoothReady) {
      await _initializeBluetooth();
      if (!_isBluetoothReady) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth não está disponível ou ativado'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // Verifica se já está escaneando e para o escaneamento anterior
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    setState(() {
      _scanResults = [];
      _isScanning = true;
    });

    try {
      // Inicia o escaneamento com um timeout mais longo
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      );
      
      // Aguarda o tempo do escaneamento
      await Future.delayed(const Duration(seconds: 10));
      
    } catch (e) {
      debugPrint('Erro ao iniciar escaneamento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao escanear: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      // Certifique-se de que o escaneamento seja interrompido mesmo se ocorrer um erro
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
      
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Bluetooth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MacConfigPage(),
                ),
              );
            },
            tooltip: 'Configurar MAC manualmente',
          ),
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : 'Dispositivo Desconhecido'),
                  subtitle: Text(result.device.id.id),
                  trailing: Text('${result.rssi} dBm'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BluetoothPage(
                          macAddress: result.device.remoteId.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}