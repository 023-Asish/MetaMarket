import 'package:flutter/material.dart';
import 'package:manpower_management/screens/TempService.dart';
import 'package:manpower_management/screens/products.dart';
import 'package:manpower_management/screens/Product_Cart.dart';
import 'package:manpower_management/screens/user_profile.dart';



class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _logoutConfirmationShowing = false;
  List pages = [
    ServicePage(),
    ProductPage(),
    UserProfileScreen(),
  ];
  int _selected =0;
  int currentIndex =0;

  void changeSelected(int index){
    setState(() {
      _selected = index;
    });
  }
  void onTap(index){
    setState(() {
      currentIndex=index;
    });
  }

  Future<bool> _onBackPressed() async {
    bool goBack = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Exit From The App?'),
          actions: [
            TextButton(
              onPressed: () {
                goBack = false;
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                goBack = true;
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
    return goBack;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child:
        Scaffold(
      // backgroundColor: Color(0xff527db8),

      appBar:AppBar(
        title: const Text("Manpower Management"),
        // centerTitle: true,
        backgroundColor: Colors.orange,
        toolbarHeight: 42,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Product_Cart()));
            },
            icon: const Icon(
              Icons.shopping_cart_rounded,
              size: 30,
            ),
          ),
        ],
      ),


      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // selectedFontSize: 0,
        // unselectedFontSize: 0,

        showSelectedLabels: true,
        showUnselectedLabels:true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: onTap,
        currentIndex: currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.withOpacity(0.95),
        elevation: 0,
        items: [
          BottomNavigationBarItem(label:"services",icon: Icon(Icons.handyman)),
          BottomNavigationBarItem(label:"products",icon: Icon(Icons.store_mall_directory)),
          BottomNavigationBarItem(label:"profile",icon: Icon(Icons.person)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image:AssetImage('assets/images/animation.png'),
                    fit: BoxFit.cover,
                  )
              ),
              child: Column(
                children: [
                  // Image(
                  //   image: AssetImage('assets/images/dp.png'),
                  // ),
                  // Text('Welcome',
                  // style: TextStyle(
                  //   fontSize: 30,
                  //   color: Colors.white,
                  // ),)
                ],
              ),
            ),

            ListTile(
              selected: _selected==0,
              leading: Icon(
                  Icons.account_circle,
                  size:25
              ),
              title: Text(
                'Accounts',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(0);
              },
            ),
            ListTile(
              selected: _selected==3,
              leading: Icon(
                  Icons.history,
                  size:25
              ),
              title: Text(
                'History',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(3);
              },
            ),
            ListTile(
              selected: _selected==4,
              leading: Icon(
                  Icons.settings,
                  size:25
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(4);
              },
            ),
            ListTile(
              selected: _selected==5,
              leading: Icon(
                  Icons.payment,
                  size:25
              ),
              title: Text(
                'Payments',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(5);
              },
            ),
            ListTile(
              selected: _selected==6,
              leading: Icon(
                  Icons.help,
                  size:25
              ),
              title: Text(
                'Help',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(6);
              },
            ),
            ListTile(
              selected: _selected==7,
              leading: Icon(
                  Icons.help,
                  size:25
              ),
              title: Text(
                'About us',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(7);
              },
            ),
            ListTile(
              selected: _selected==8,
              leading: Icon(
                  Icons.key,
                  size:25
              ),
              title: Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(8);
              },
            ),
            ListTile(
              selected: _selected==9,
              leading: Icon(
                  Icons.help,
                  size:25
              ),
              title: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(9);
              },
            ),
            ListTile(
              selected: _selected==10,
              leading: Icon(
                  Icons.contact_phone,
                  size:25
              ),
              title: Text(
                'Contact us',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: (){
                changeSelected(10);
              },
            ),
          ],
        ),
      ),
      // bottomNavigationBar: Bottom(),
    ),
    );
  }
}