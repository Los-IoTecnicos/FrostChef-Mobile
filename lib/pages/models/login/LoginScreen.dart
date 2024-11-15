import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frostchef/pages/models/login/providers/AuthProvider.dart';
import 'package:frostchef/pages/models/login/RegisterScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../routes/principal/HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  bool _isEmailEmpty = false;
  bool _isPasswordEmpty = false;
  int _loginAttempts = 0;
  DateTime? _lockoutEndTime;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, // Prevents resizing on keyboard open
        backgroundColor: Colors.lightBlue[50],
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/login_frostChefPerson.webp',
                  height: 160,
                  fit: BoxFit.contain,
                ),
                Text(
                  "FrostChef",
                  style: GoogleFonts.pacifico(
                    textStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _handleLogin(context);
                          }
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Don\'t have an account? ',
                              style: TextStyle(color: Colors.black)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    setState(() {
      _showEmailError = false;
      _showPasswordError = false;
      _isEmailEmpty = _emailController.text.trim().isEmpty;
      _isPasswordEmpty = _passwordController.text.trim().isEmpty;
    });

    if (_isEmailEmpty || _isPasswordEmpty) {
      setState(() {
        if (_isEmailEmpty) _showEmailError = true;
        if (_isPasswordEmpty) _showPasswordError = true;
      });
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    Duration delayDuration;

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      delayDuration = Duration(seconds: 2);
    } else {
      Fluttertoast.showToast(
        msg: "No Internet connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      await Future.delayed(delayDuration);

      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "Successfully validated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _handleLoginError(e, context);
    }
  }

  void _handleLoginError(Object e, BuildContext context) {
    String errorMessage;

    if (e.toString().contains('Unauthorized')) {
      errorMessage = 'Invalid or unauthenticated email. Please check your email.';
    } else if (e.toString().contains('Invalid email format') ||
        e.toString().contains('Email not authenticated')) {
      errorMessage = 'Invalid email format. Please enter it correctly.';
    } else if (e.toString().contains('Invalid password')) {
      errorMessage = 'Incorrect password. Please enter the correct password.';
    } else {
      errorMessage = 'An unexpected error occurred. Please try again.';
    }

    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[850],
      textColor: Colors.white,
      fontSize: 14.0,
    );

    _loginAttempts += 1;
    if (_loginAttempts >= 3) {
      _handleAccountLock(context);
    }
  }

  void _handleAccountLock(BuildContext context) {
    if (_lockoutEndTime == null) {
      _lockoutEndTime = DateTime.now().add(Duration(minutes: 10));
    } else {
      _lockoutEndTime = DateTime.now().add(Duration(days: 5));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Material(
              borderRadius: BorderRadius.circular(15),
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: Colors.white, size: 40),
                    SizedBox(height: 20),
                    Text(
                      'Account Locked',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You have exceeded the maximum number of login attempts. Please try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
