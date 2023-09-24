import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsForm extends StatefulWidget {
  const UserDetailsForm({Key? key}) : super(key: key);
  @override
  State<UserDetailsForm> createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();
  final countryController = TextEditingController();
  final mobileController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('user_users')
          .add(
          {
            'email': FirebaseAuth.instance.currentUser?.email,
            'name': nameController.text,
            'address': addressController.text,
            'age': int.parse(ageController.text),
            'country': countryController.text,
            'mobile': mobileController.text,
            'pincode': pincodeController.text,
            'state': stateController.text,
          }
      );
      print('Saved');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    ageController.dispose();
    countryController.dispose();
    mobileController.dispose();
    pincodeController.dispose();
    stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.orange,
        toolbarHeight: 42,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter country';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: pincodeController,
                  decoration: const InputDecoration(labelText: 'Pincode'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pincode';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}


