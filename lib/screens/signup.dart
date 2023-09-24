import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manpower_management/reusable_components/coponent.dart';

import '../utils/color_utils.dart';
import 'main_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient:  LinearGradient(colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120,20,0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Username", Icons.person_outline,false,_userNameTextController),
                const SizedBox(
                height: 20,
                ),
                reusableTextField("Enter Email Id", Icons.person_outline,false,_emailTextController),
                const SizedBox(
                height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline,true,_passwordTextController),
                const SizedBox(
                height: 20,
                ),
                signInSignUpButton(context, false,(){
                  FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text).then((value){
                      print("Created New Account...");
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>MainPage()));
                  }).onError((error, stackTrace){
                    print("Error : ${error.toString()}");
                  });

                })
              ],
          ),
      ))),
    );
  }
}
