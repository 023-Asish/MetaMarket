import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manpower_management/screens/signup.dart';
import 'package:manpower_management/utils/color_utils.dart';

import '../reusable_components/coponent.dart';
import 'main_page.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  void _resetPassword() async {
    setState(() {
      _emailError = null;
    });

    final email = _emailTextController.text.trim();

    // check if email field is empty
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email';
      });
      return;
    }

    // validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = 'Invalid email format';
      });
      return;
    }

    // send password reset email
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Password Reset'),
            content: const Text('A password reset email has been sent to your email address.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // if (e.code == 'user-not-found') {
      //   setState(() {
      //     _emailError = 'User not found for the given email address';
      //   });
      // }
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                hexStringToColor("CB2B93"),
                hexStringToColor("9546C4"),
                hexStringToColor("5E61F4")
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
            EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo.png"),
                SizedBox(
                  height: 30,
                ),
                reusableTextField(
                    "Enter Username",
                    Icons.person_outline,
                    false,
                    _emailTextController,
                    errorText: _emailError),
                SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Enter Password",
                    Icons.lock_outline,
                    true,
                    _passwordTextController,
                    errorText: _passwordError
                ),
                SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, true, _handleSignIn),
                signUpOption(),
                forgotPasswordOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        )
      ],
    );
  }

  Widget forgotPasswordOption() {
    return TextButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Reset Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Enter your email address to reset your password"),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailTextController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      errorText: _emailError,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () {
                      _resetPassword();
                    },
                    child: Text("Reset")),
              ],
            ));
      },
      child: Text("Forgot Password?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18)
      ),
    );
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailTextController.text.trim();
    final password = _passwordTextController.text.trim();

    // check if email and password fields are empty
    if (email.isEmpty || password.isEmpty) {
      if (email.isEmpty) {
        setState(() {
          _emailError = 'Please enter your email';
        });
      }
      if (password.isEmpty) {
        setState(() {
          _passwordError = 'Please enter your password';
        });
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Your Email or Password is Empty'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = 'Invalid email format';
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Invalid email format'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // sign in with Firebase Authentication
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
      else{
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('User not found for the given email address'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _emailError = 'User not found for the given email address';
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('User not found for the given email address'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      else if (e.code == 'wrong-password') {
        setState(() {
          _passwordError = 'Invalid password';
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Invalid password'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
