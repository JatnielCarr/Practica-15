import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';
import 'services/supabase_service.dart';
import 'services/audio_service.dart';
import 'services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseService.initialize();

  // Inicializar Audio
  await AudioService().initialize();
  AudioService().playBackgroundMusic();

  // Inicializar AdMob
  await AdMobService().initialize();

  // Forzar orientación horizontal
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angry Birds Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const GameScreen(),
    );
  }
}
