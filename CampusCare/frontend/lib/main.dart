import 'package:flutter/material.dart';
import 'api.dart';
import 'screens/admin_home.dart';
import 'screens/login_screen.dart';
import 'screens/student_home.dart';

// Campus Care palette
const navy = Color(0xFF162D4E);
const blue = Color(0xFF2B6CB0);
const green = Color(0xFF2ECC94);
const orange = Color(0xFFF6A623);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.load();
  runApp(const CampusCareApp());
}

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget home = const LoginScreen();
    if (Session.isLoggedIn) {
      home = Session.isAdmin ? const AdminHome() : const StudentHome();
    }
    return MaterialApp(
      title: 'Campus Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: blue),
        appBarTheme: const AppBarTheme(
            backgroundColor: navy, foregroundColor: Colors.white),
        useMaterial3: true,
      ),
      home: home,
    );
  }
}
