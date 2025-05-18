import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_virtual_refrigerator/viewmodels/forgot_password_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/forgot_password_view.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import '../viewmodels/signup_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../views/signup_view.dart';
import '../views/login_view.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()), 
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()), 
      ],
      child: MaterialApp(
        title: 'Smart Virtual Refrigerator',
        theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Color(0xFFFBFCFE),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionColor: Colors.black,
            selectionHandleColor: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            side: BorderSide(color: Colors.transparent),
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.black;
              }
              return Colors.grey;
            }),
            checkColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        home: LoginView(), 
      ),
    );
  }
}
