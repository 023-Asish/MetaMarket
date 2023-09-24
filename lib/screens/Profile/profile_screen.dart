import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
               SizedBox(
                 width: 120, height: 120,
                 child: Image(image: AssetImage('assets/image/dp.png'),),
               )
            ],
          ),
        ),
      )
    );
  }
}
