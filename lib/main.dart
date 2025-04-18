import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/mac_config_page.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Arduino Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MacConfigPage(),
    );
  }
}
