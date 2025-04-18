import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import 'bluetooth_page.dart';

class MacConfigPage extends StatefulWidget {
  const MacConfigPage({Key? key}) : super(key: key);

  @override
  State<MacConfigPage> createState() => _MacConfigPageState();
}

class _MacConfigPageState extends State<MacConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _macController = TextEditingController();
  final _storageService = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedMac();
  }

  Future<void> _loadSavedMac() async {
    final savedMac = await _storageService.getMacAddress();
    if (savedMac != null) {
      _macController.text = savedMac;
    }
    setState(() {
      _isLoading = false;
    });
  }

  String? _validateMacAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um endereço MAC';
    }

    // Regex para validar o formato do endereço MAC (XX:XX:XX:XX:XX:XX)
    final RegExp macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!macRegex.hasMatch(value)) {
      return 'Formato inválido. Use XX:XX:XX:XX:XX:XX';
    }

    return null;
  }

  Future<void> _saveMacAndNavigate() async {
    if (_formKey.currentState!.validate()) {
      await _storageService.saveMacAddress(_macController.text.toUpperCase());
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BluetoothPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração do Bluetooth'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Digite o endereço MAC do dispositivo Bluetooth',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _macController,
                decoration: const InputDecoration(
                  labelText: 'Endereço MAC',
                  hintText: 'XX:XX:XX:XX:XX:XX',
                  border: OutlineInputBorder(),
                ),
                validator: _validateMacAddress,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  // Formata automaticamente o texto para o formato MAC
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String text = newValue.text.toUpperCase();
                    text = text.replaceAll(RegExp(r'[^0-9A-F]'), '');
                    
                    String formatted = '';
                    for (int i = 0; i < text.length && i < 12; i++) {
                      if (i > 0 && i % 2 == 0) {
                        formatted += ':';
                      }
                      formatted += text[i];
                    }
                    
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMacAndNavigate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Conectar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _macController.dispose();
    super.dispose();
  }
} 