import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'transporter_page.dart';
import 'manufacturer_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getBool("logged_in") ?? false;
  String? role = prefs.getString("role");

  runApp(MyApp(loggedIn: loggedIn, role: role));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  final String? role;

  const MyApp({super.key, required this.loggedIn, this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kirana's Professional",
      debugShowCheckedModeBanner: false,
      home: loggedIn
          ? role == "manufacturer"
              ? ManufacturerPage()
              : TransporterPage()
          : LoginPage(),
    );
  }
}
