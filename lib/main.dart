import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forçar orientação horizontal
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothPage(),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothDevice? _connectedDevice;
  String _status = 'Desconectado';
  final String targetMac = "00:00:00:00:00:00";
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isHoldingButton = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _sendCommand(String command) async {
    if (_writeCharacteristic != null) {
      try {
        await _writeCharacteristic!.write(command.codeUnits);
        setState(() {
          _status = 'Comando enviado: $command';
        });
      } catch (e) {
        setState(() {
          _status = 'Erro ao enviar comando: $e';
        });
      }
    } else {
      setState(() {
        _status = 'Característica de escrita não encontrada';
      });
    }
  }

  void _handleButtonPress(String command) {
    if (!_isHoldingButton) {
      _sendCommand(command);
    }
  }

  void _startContinuousCommand(String command) {
    _isHoldingButton = true;
    _sendContinuousCommand(command);
  }

  void _stopContinuousCommand() {
    _isHoldingButton = false;
  }

  Future<void> _sendContinuousCommand(String command) async {
    while (_isHoldingButton) {
      await _sendCommand(command);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> _checkPermissions() async {
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

    if (allGranted) {
      _connectToDevice();
    } else {
      setState(() {
        _status = 'Permissões necessárias não concedidas';
      });
    }
  }

  Future<void> _connectToDevice() async {
    setState(() {
      _status = 'Procurando dispositivo...';
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      await for (final result in FlutterBluePlus.scanResults) {
        for (ScanResult r in result) {
          if (r.device.remoteId.toString().toUpperCase() == targetMac.toUpperCase()) {
            await FlutterBluePlus.stopScan();
            
            setState(() {
              _status = 'Dispositivo encontrado, conectando...';
            });

            await r.device.connect();
            
            // Descobrir serviços e características
            List<BluetoothService> services = await r.device.discoverServices();
            for (BluetoothService service in services) {
              for (BluetoothCharacteristic characteristic in service.characteristics) {
                if (characteristic.properties.write) {
                  _writeCharacteristic = characteristic;
                  break;
                }
              }
            }
            
            setState(() {
              _connectedDevice = r.device;
              _status = 'Conectado a ${r.device.remoteId}';
            });
            
            return;
          }
        }
      }
      
      setState(() {
        _status = 'Dispositivo não encontrado';
      });
    } catch (e) {
      setState(() {
        _status = 'Erro: $e';
      });
    }
  }

  Future<void> _disconnectDevice() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        setState(() {
          _connectedDevice = null;
          _writeCharacteristic = null;
          _status = 'Desconectado';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Erro ao desconectar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle do Carrinho'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Status: $_status',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.bluetooth_disabled),
            onPressed: _disconnectDevice,
            tooltip: 'Desconectar',
          ),
        ],
      ),
      body: Row(
        children: [
          // Controles de movimento (lado esquerdo)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão W (Frente)
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: GestureDetector(
                      onTapDown: (_) => _startContinuousCommand('w'),
                      onTapUp: (_) => _stopContinuousCommand(),
                      onTapCancel: () => _stopContinuousCommand(),
                      child: ElevatedButton(
                        onPressed: () => _handleButtonPress('w'),
                        child: Text('w', style: TextStyle(fontSize: 30)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Botões A, S, D
                  Row(
          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: GestureDetector(
                          onTapDown: (_) => _startContinuousCommand('a'),
                          onTapUp: (_) => _stopContinuousCommand(),
                          onTapCancel: () => _stopContinuousCommand(),
                          child: ElevatedButton(
                            onPressed: () => _handleButtonPress('a'),
                            child: Text('a', style: TextStyle(fontSize: 30)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: GestureDetector(
                          onTapDown: (_) => _startContinuousCommand('s'),
                          onTapUp: (_) => _stopContinuousCommand(),
                          onTapCancel: () => _stopContinuousCommand(),
                          child: ElevatedButton(
                            onPressed: () => _handleButtonPress('s'),
                            child: Text('s', style: TextStyle(fontSize: 30)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: GestureDetector(
                          onTapDown: (_) => _startContinuousCommand('d'),
                          onTapUp: (_) => _stopContinuousCommand(),
                          onTapCancel: () => _stopContinuousCommand(),
                          child: ElevatedButton(
                            onPressed: () => _handleButtonPress('d'),
                            child: Text('d', style: TextStyle(fontSize: 30)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
            ),
          ],
        ),
      ),
          ),
          // Botões de ação (lado direito)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () => _sendCommand('b'),
                        child: Text('ATACAR', style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () => _sendCommand('l'),
                        child: Text('PARAR', style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () => _sendCommand('x'),
                        child: Text('LIGAR\nFARÓIS', 
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    SizedBox(
                      height: 60,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () => _sendCommand('c'),
                        child: Text('DESLIGAR\nFARÓIS', 
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 320,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _checkPermissions,
                    child: Text('Reconectar', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_connectedDevice != null) {
      _connectedDevice!.disconnect();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
