import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';

class BluetoothScanScreen extends StatefulWidget {
  final Function(String) onDeviceSelected;

  const BluetoothScanScreen({Key? key, required this.onDeviceSelected}) : super(key: key);

  @override
  _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  final BleService _bluetoothService = BleService();
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _bluetoothService.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (!mounted) return;

    setState(() {
      _scanResults = [];
      _isScanning = true;
    });

    try {
      await _bluetoothService.startScan();

      _bluetoothService.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults = results;
          });
        }
      }, onError: (error) {
        print('Erro durante o scan: $error');
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          _showError('Erro ao escanear: $error');
        }
      });

    } catch (e) {
      print('Erro ao iniciar scan: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showError('Erro ao iniciar scan: $e');
      }
    }

    // Atualiza o estado após o timeout do scan
    Future.delayed(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Dispositivo'),
        actions: [
          if (_isScanning)
            Container(
              margin: EdgeInsets.all(16),
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _startScan,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _scanResults.length,
        itemBuilder: (context, index) {
          final result = _scanResults[index];
          final device = result.device;
          final name = device.localName.isNotEmpty
              ? device.localName
              : device.remoteId.toString();

          return ListTile(
            title: Text(name),
            subtitle: Text(device.remoteId.toString()),
            trailing: Text('${result.rssi} dBm'),
            onTap: () {
              widget.onDeviceSelected(device.remoteId.toString());
              Navigator.pop(context); // Fecha a tela de scan
              Navigator.pop(context); // Fecha a tela de configurações
            },
          );
        },
      ),
    );
  }
} 