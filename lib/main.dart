import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_virtual_refrigerator/viewmodels/add_ingredients_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/forgot_password_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/fridge_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/add_ingredients_barcode_view.dart';
import 'package:smart_virtual_refrigerator/views/add_ingredients_view.dart';
import 'package:smart_virtual_refrigerator/views/signup_view.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import '../viewmodels/signup_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../views/login_view.dart'; 
import '../views/fridge_page.dart'; 
import '../views/home_page.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Could not load .env: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Import this: import 'package:firebase_auth/firebase_auth.dart';
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoggedIn = user != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // You can customize this loading screen
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => FridgeViewModel()),
        ChangeNotifierProvider(create: (_) => IngredientViewModel()),
      ],
      child: MaterialApp(
        title: 'Smart Virtual Refrigerator',
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFFBFCFE),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionColor: Colors.black,
            selectionHandleColor: Colors.black,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            side: const BorderSide(color: Colors.transparent),
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.black;
              }
              return Colors.grey;
            }),
            checkColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        debugShowCheckedModeBanner: false,

        home: const FridgePage(),



      ),
    );
  }
}
