import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_virtual_refrigerator/models/leftover.dart';
import 'package:smart_virtual_refrigerator/viewmodels/add_ingredients_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/forgot_password_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/fridge_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/update_ingredients_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/leftover_viewmodel.dart';
import 'package:smart_virtual_refrigerator/viewmodels/profile_viewmodel.dart';
import 'package:smart_virtual_refrigerator/views/add_ingredients_barcode_view.dart';
import 'package:smart_virtual_refrigerator/views/add_ingredients_view.dart';
import 'package:smart_virtual_refrigerator/views/signup_view.dart';

import 'package:smart_virtual_refrigerator/views/home_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import '../viewmodels/signup_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/recipe_viewmodel.dart';
import '../viewmodels/ingredient_viewmodel.dart';

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
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => FridgeViewModel()),
        ChangeNotifierProvider(create: (_) => AddIngredientViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => UpdateIngredientsViewModel()),
        ChangeNotifierProvider(create: (_) => IngredientViewModel()),
        ChangeNotifierProvider(create: (_) => LeftoverViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
      ],
      child: MaterialApp(
        title: 'Smart Virtual Refrigerator',
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFE633),
            brightness: Brightness.light,
          ).copyWith(
            surfaceTint: Colors.transparent,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Applies to actions in AlertDialog
            ),
          ),
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
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(16)), // same radius
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(16)),// Border color when focused
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
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Colors.black,
          ),
          dividerTheme: const DividerThemeData(
            color: Colors.black,
            thickness: 1,
            space: 1,
          ),
          appBarTheme: AppBarTheme(
            toolbarHeight: 100,
            backgroundColor: Color(0xFFFBFCFE),
            surfaceTintColor: Color(0xFFFBFCFE),
            foregroundColor: Colors.black,
            elevation: 4,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.white,
            selectedColor: Color(0xFFFFE633),
            secondarySelectedColor: Color(0xFFFFE633),
            labelStyle: const TextStyle(color: Colors.grey),
            secondaryLabelStyle: const TextStyle(color: Colors.black),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            showCheckmark: false,
            elevation: 0,
            pressElevation: 0,
            surfaceTintColor: Colors.transparent,
            side: BorderSide.none,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Color(0xFFFFE633),
              foregroundColor: Colors.black,
              elevation: 0, // adjust for desired shadow depth
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // optional: for rounded corners
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color(0xFFFBFCFE),
            surfaceTintColor: Color(0xFFFBFCFE),
          ),
          switchTheme: SwitchThemeData(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            thumbColor: MaterialStateProperty.all(Colors.white),
            trackColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return Color(0xFFFFE633); // track when on
              }
              return Color(0xFFF2F3F8); // track when off
            }),
            trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.transparent; // No outline when ON
              }
              return Colors.transparent; // No outline when OFF
            }),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.black,
            contentTextStyle: TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          dialogTheme: DialogTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            contentTextStyle: TextStyle(color: Colors.black, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,

        ),
        debugShowCheckedModeBanner: false,

        home: _isLoggedIn ? const HomePage() : const LoginView(),


      ),
    );
  }
}
