import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manpower_management/screens/Product_Cart.dart';
import 'package:manpower_management/screens/Service_History.dart';
import 'package:manpower_management/screens/signin.dart';
import 'Complete_profile.dart';
import 'package:get/get.dart';


class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String ?_userEmail;
  String ?pickedImage;
  bool is_loading_image = true;

  // Fetch user email from database
  void fetchUserEmail() async {
    User user = _auth.currentUser!;
    DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
    setState(() {
      _userEmail = userDoc['email'];
    });
  }

  void _showConfirmationLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text("Confirm Booking"),
          content: Text("Are you sure you want to Logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Log Out"),
              onPressed: (){
                try {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  );
                } catch (e) {
                  print('Error occurred while logging out: $e');
                }},
            ),
          ],
        );
      },
    );
  }

  Future<void> getUserProfilePhoto() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String photoName = '$uid.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('user_profile_photo/$photoName');

      try {
        String downloadUrl = await ref.getDownloadURL();
        setState(() {
          pickedImage = downloadUrl;
          is_loading_image = false;
        });
        // print('picked image fetched url: $pickedImage');
      } catch (error) {
        setState(() {
          pickedImage = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgLD1Cgfq6yHKJqMyacqlNGPClJO9Np2M4KQ&usqp=CAU';
          is_loading_image = false;
        }); // Set a default value for pickedImage
        debugPrint(error.toString());
      }
    }
    // print('This is picked image: $pickedImage, is loading = $is_loading_image');
  }

  void imagePickerOption() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 270,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pic Image From",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("CAMERA"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.orange, // text color
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("GALLERY"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.orange, // text color
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        pickedImage = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgLD1Cgfq6yHKJqMyacqlNGPClJO9Np2M4KQ&usqp=CAU';
                        is_loading_image = false;
                      });
                      Get.back();
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Remove"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.orange, // text color
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("CANCEL"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.orange, // text color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> upload_photo(File imageFile) async {
    final String documentId = '${FirebaseAuth.instance.currentUser?.uid}';
    try {
      final Reference ref = FirebaseStorage.instance.ref().child('user_profile_photo/$documentId.jpg');
      final TaskSnapshot uploadTask = await ref.putFile(imageFile);
      final String downloadUrl = await uploadTask.ref.getDownloadURL();
      // print('picked image uploaded url: $downloadUrl');
      setState(() {
        pickedImage = downloadUrl;
        is_loading_image = false;
      });
      await FirebaseFirestore.instance.collection('user_profile_photo').doc(documentId).update({
        'photoUrl': downloadUrl,
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      setState(() {
        is_loading_image = true;
        upload_photo(File(photo.path));
      });
      Get.back();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    getUserProfilePhoto();
  }

  @override
  Widget build(BuildContext context) {
    // var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 2),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    child: ClipOval(
                      child:
                      is_loading_image ? CircularProgressIndicator():
                      Image.network(
                            pickedImage!,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                      )
                      // Image.network(
                      //       '',
                      //       width: 130,
                      //       height: 130,
                      //       fit: BoxFit.cover,
                      //     ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      onPressed:imagePickerOption,
                      icon: const Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10.0),

            Text('${FirebaseAuth.instance.currentUser?.email}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(color: Colors.grey,thickness: 2),
            ),
            ProfileMenuWidget(title: "Complete Your Profile", icon: Icons.account_circle_outlined, onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>UserDetailsForm()));
            }),
            ProfileMenuWidget(title: "My Cart", icon: Icons.shopping_cart_outlined, onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Product_Cart()));
            }),
            // ProfileMenuWidget(title: "My Orders", icon: Icons.reorder, onPress: () {}),
            // ProfileMenuWidget(title: "Payments", icon: Icons.payment_outlined, onPress: () {}),
            ProfileMenuWidget(title: "Service History", icon: Icons.history, onPress: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ServiceHistory()));
            }),
            ProfileMenuWidget(title: "Product History", icon: Icons.history, onPress: () {}),
            ProfileMenuWidget(title: "Feedbacks", icon: Icons.feed_outlined, onPress: () {}),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(color: Colors.grey,thickness: 2),
            ),
            const SizedBox(height: 10),
            ProfileMenuWidget(title: "Information", icon: Icons.settings, onPress: () {}),
            ProfileMenuWidget(
                title: "Logout",
                icon: Icons.logout_outlined,
                textColor: Colors.red,
                endIcon: false,
                onPress: (){
                  _showConfirmationLogout(context);
                },
            )
          ],
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white24,
        ),
        child: Icon(icon, color: Colors.blueGrey),
      ),
      title: Text(title, style: TextStyle(fontSize: 18)),
      trailing: endIcon? Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.white24,
          ),
          child: const Icon(LineAwesomeIcons.angle_right, size: 20.0, color: Colors.grey)): null,
    );
  }
}