import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../views/login_view.dart'; 

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          TextButton(
            onPressed: () {
              // Add your sign-out logic here
              // You may want to use FirebaseAuth or your own AuthService to sign out
              // Example: FirebaseAuth.instance.signOut();
              
              // You could navigate to the login screen after sign-out
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginView()), // Navigate back to login view
              );
            },
            child: Text(
              "Sign Out",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 350,
            ),
            // Add any additional content you want here
          ],
        ),
      ),
    );
  }
}
