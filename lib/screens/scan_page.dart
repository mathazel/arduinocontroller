import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bluetooth_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<BluetoothDevice> _devicesList = [];
  bool _isScanning = false;
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _bluetoothState = state;
      });
        // Se o Bluetooth for desligado enquanto estivermos na página, pare o escaneamento
        if (state != BluetoothAdapterState.on && _isScanning) {
            _stopScan();
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Bluetooth desligado. Escaneamento parado.")),
                );
            }
        }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initBluetoothAndScan();
  }

  // Método principal para verificar permissões e estado do Bluetooth e iniciar scan
  Future<void> _initBluetoothAndScan() async {
    bool permissionsGranted = await _checkAndRequestPermissions();
    if (!permissionsGranted) {
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Permissões Bluetooth e Localização são necessárias para escanear.")),
          );
      }
      return;
    }

    _bluetoothState = await FlutterBluePlus.adapterState.first;
    if (_bluetoothState != BluetoothAdapterState.on) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Por favor, ligue o Bluetooth.")),
            );
        }
        return;
    }

    _startScan();
  }

  // Verifica e solicita permissões necessárias
  Future<bool> _checkAndRequestPermissions() async {
      if (Theme.of(context).platform == TargetPlatform.android) {
          if (await Permission.bluetoothScan.isDenied || await Permission.bluetoothConnect.isDenied) {
              Map<Permission, PermissionStatus> statuses = await [
                Permission.bluetoothScan,
                Permission.bluetoothConnect,
              ].request();
              return statuses[Permission.bluetoothScan]?.isGranted == true &&
                     statuses[Permission.bluetoothConnect]?.isGranted == true;
          }
            return await Permission.bluetoothScan.isGranted && await Permission.bluetoothConnect.isGranted;
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
          return true; // Assume que no iOS é handled automaticamente ou não requer permissões runtime explícitas BLE
      }
      return true;
  }

  // Inicia o escaneamento de dispositivos
  void _startScan() {
      if (_bluetoothState != BluetoothAdapterState.on) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Bluetooth desligado. Não é possível escanear.")),
          );
          return;
      }

    setState(() {
      _isScanning = true;
      _devicesList = [];
    });

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!_devicesList.contains(r.device)) {
          setState(() {
            _devicesList.add(r.device);
          });
        }
      }
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    FlutterBluePlus.isScanning.listen((scanning) {
        if (!scanning) {
            setState(() {
                _isScanning = false;
            });
             if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Escaneamento finalizado.")),
                );
             }
        }
    });
  }
  void _stopScan() {
      FlutterBluePlus.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurar Dispositivos Bluetooth'),
        actions: [
            // Botão para iniciar/parar escaneamento
            if (_bluetoothState == BluetoothAdapterState.on)
              _isScanning
                  ? IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: _stopScan,
                      tooltip: 'Parar Escaneamento',
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _startScan,
                      tooltip: 'Escanear Dispositivos',
                    ),
        ],
      ),
      body: _bluetoothState != BluetoothAdapterState.on
          ? Center(child: Text("Bluetooth está ${_bluetoothState.toString().split('.').last}. Por favor, ligue-o."))
          : _isScanning && _devicesList.isEmpty
               ? const Center(child: CircularProgressIndicator())
               : _devicesList.isEmpty
                    ? Center(child: Text("Nenhum dispositivo encontrado.${_isScanning ? ' Procurando...' : ' Certifique-se que o dispositivo está ligável e tente escanear novamente.'}"))
                    : ListView.builder(
                        itemCount: _devicesList.length,
                        itemBuilder: (context, index) {
                          final device = _devicesList[index];
                          return ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(device.name.isNotEmpty ? device.name : 'Dispositivo Desconhecido'),
                            subtitle: Text(device.remoteId.str),
                            onTap: () {
                              _stopScan();
                              _connectToDevice(device);
                            },
                          );
                        },
                      ),
    );
  }

  // TODO: Implementar este método para conectar ao dispositivo selecionado
  void _connectToDevice(BluetoothDevice device) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BluetoothPage(
                  // TODO: Passar o dispositivo ou informações necessárias para a BluetoothPage
              ),
          ),
      );
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }
}