import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/homePage.dart';
import 'package:step_counter/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static DateTime time = DateTime.now();
  static DateFormat formatter = DateFormat('dd-MM-yyyy');
  final String formatted = formatter.format(time);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  getCurrentUser() async {
    user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      );
    }
  }
}
