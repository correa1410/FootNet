import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:footnet/screens/news_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart' as home_screen; 
import 'screens/live_data_screen.dart'; 
import 'screens/match_screen.dart';
import 'screens/profile_screen.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/home': (context) => home_screen.HomeScreen(), // Usa el alias aquí
        '/liveData': (context) => LiveDataScreen(),
        '/match': (context) => MatchScreen(),
        '/profile': (context) => ProfileScreen(),
        '/login': (context) => LoginScreen(),
        '/news': (context) => NewsScreen(),
      },
    );
  }
}