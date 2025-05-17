import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/bluetooth_service.dart';
import '../widgets/movement_panel.dart';
import '../widgets/action_panel.dart';

class BluetoothPage extends StatefulWidget {
  final String? macAddress;
  
  const BluetoothPage({
    Key? key,
    this.macAddress,
  }) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> with WidgetsBindingObserver {
  final BluetoothService _bluetoothService = BluetoothService();
  bool _isHoldingButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      _bluetoothService.disconnect();
    }
  }

  Future<void> _initBluetoothConnection() async {
    bool permissionsGranted = await _bluetoothService.checkPermissions();
    if (permissionsGranted) {
      // Se tiver um MAC específico, salva ele antes de tentar conectar
      if (widget.macAddress != null) {
        await _bluetoothService.saveMacAddress(widget.macAddress!);
      }
      
      // Tentar conectar até 3 vezes com um pequeno intervalo entre as tentativas
      bool connected = false;
      int attempts = 0;

      while (!connected && attempts < 3) {
        attempts++;
        connected = await _bluetoothService.connectToDevice();

        if (!connected && attempts < 3) {
          // Aguardar um pouco antes de tentar novamente
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }

      if (!connected && mounted) {
        // Mostrar mensagem de erro se todas as tentativas falharem
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível conectar ao dispositivo. Tente reconectar.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleButtonPress(String command) {
    if (!_isHoldingButton) {
      _bluetoothService.sendCommand(command);
    }
  }

  void _startContinuousCommand(String command) {
    setState(() {
      _isHoldingButton = true;
    });
    _sendContinuousCommand(command);
  }

  void _stopContinuousCommand() {
    setState(() {
      _isHoldingButton = false;
    });
  }

  Future<void> _sendContinuousCommand(String command) async {
    while (_isHoldingButton) {
      await _bluetoothService.sendCommand(command);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle do Carrinho'),
        actions: [
          // Botão de reconectar na AppBar antes do status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                // Se tiver um MAC específico, salva ele antes de tentar conectar
                if (widget.macAddress != null) {
                  await _bluetoothService.saveMacAddress(widget.macAddress!);
                }
                await _initBluetoothConnection();
              },
              icon: const Icon(Icons.bluetooth_searching, size: 20),
              label: const Text('Conectar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder<String>(
                valueListenable: _bluetoothService.connectionStatus,
                builder: (context, status, child) {
                  return Text(
                    'Status: $status',
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: _bluetoothService.disconnect,
            tooltip: 'Desconectar',
          ),
        ],
      ),
      body: Row(
        children: [
          // Controles de movimento (lado esquerdo)
          Expanded(
            child: MovementPanel(
              onStartContinuousCommand: _startContinuousCommand,
              onStopContinuousCommand: _stopContinuousCommand,
              onButtonPress: _handleButtonPress,
            ),
          ),

          // Botões de ação (lado direito)
          Expanded(
            child: ActionPanel(
              onCommandSend: _handleButtonPress,
              onReconnect: () {}
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bluetoothService.disconnect();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }
}