import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import '../views/viewmodels/signup_viewmodel.dart';
import '../views/signup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Virtual Refrigerator',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Color(0xFFFBFCFE),
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black, fontSize: 16),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          side: BorderSide(color: Colors.transparent),
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.black; // color when checked
            }
            return Colors.grey; // color when unchecked
          }),
          checkColor: MaterialStateProperty.all(
            Colors.white,
          ), // color of the check mark
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => SignupViewModel(),
        child: SignupView(),
      ),
    );
  }
}
