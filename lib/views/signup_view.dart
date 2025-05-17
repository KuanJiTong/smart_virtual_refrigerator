import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './viewmodels/signup_viewmodel.dart';

class SignupView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SignupViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 350,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x121F2687),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 13,
                        ),
                        label: Text(
                          'Sign Up with Google',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          side: BorderSide(color: Colors.black, width: 1.5),
                        ),
                        onPressed: vm.signupWithGoogle,
                      ),
                    ),
                    Divider(color: Colors.black),
                    Text(
                      "Name",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        fontSize: 12, // Set your desired font size here
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter your name',
                        labelStyle: TextStyle(
                          fontSize: 12, // Label text size
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.5,  // thickness when not focused
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,  // thickness when focused
                          ),
                        ),
                      ),
                      onChanged: vm.setName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        fontSize: 12, // Set your desired font size here
                      ),
                      decoration: InputDecoration(
                        labelText: 'Enter your email address',
                        labelStyle: TextStyle(
                          fontSize: 12, // Label text size
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.5,  // thickness when not focused
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,  // thickness when focused
                          ),
                        ),
                      ),
                      onChanged: vm.setEmail,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        labelText: 'At least 8 characters',
                        labelStyle: TextStyle(
                          fontSize: 12, // Label text size
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.5,  // thickness when not focused
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,  // thickness when focused
                          ),
                        ),
                      ),
                      onChanged: vm.setPassword,
                      validator: (value) {
                        if (value == null || value.length <= 6) {
                          return 'Password must be at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Checkbox(
                            value: vm.isChecked,
                            onChanged: vm.setAgreedToTerms,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'I agree with ',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'terms',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFFE633),           // Different color
                                  decoration: TextDecoration.underline,  // Underlined
                                ),
                                // Optional: Add gesture recognizer for taps if you want links
                              ),
                              TextSpan(
                                text: ' and ',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              TextSpan(
                                text: 'privacy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFFE633),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(

                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            vm.signup();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Color(0xFFFFE633), // button background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3), // rounded corners
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // text color
                          ),
                        ),
                      ),
                    ),
                    Divider(color: Colors.black),
                    Center(child: Text("Already have an account?", style: TextStyle(fontSize: 14),)),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
