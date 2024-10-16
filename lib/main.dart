import 'package:chatapp/screens/homePage.dart';
import 'package:chatapp/screens/loginPage.dart';
import 'package:chatapp/screens/registerPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyAPpH6n_1VrB2oqqMv0sriidG7GRjhJKtY",
    authDomain: 'chatapp-4ac6e.firebaseapp.com',
    projectId: 'chatapp-4ac6e',
    storageBucket: 'chatapp-4ac6e.appspot.com',
    messagingSenderId: '883289226579',
    appId: '1:883289226579:android:ed1fe0fa02f6ec688435a6',

  );

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Registerpage(),debugShowCheckedModeBanner: false,);
  }
}