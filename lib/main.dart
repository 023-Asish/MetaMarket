import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manpower_management/screens/media.dart';
import 'package:manpower_management/screens/signin.dart';
import 'package:firebase_core/firebase_core.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Outfit',
      ),
      home: const SignIn(),
      debugShowCheckedModeBanner: false,
    );
  }
}