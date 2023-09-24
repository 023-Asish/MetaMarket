//
// import 'package:flutter/material.dart';
//
// class bottom_nav extends StatelessWidget {
//   const bottom_nav({Key? key}) : super(key: key);
//
//   int currentIndex=0;
//   void onTap(int index){
//     setState((){
//       currentIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationBar(
//         selectedFontSize: 0,
//         unselectedFontSize: 0,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         // onTap: onTap,
//         // currentIndex: currentIndex,
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.grey.withOpacity(0.5),
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         elevation: 0,
//         items: [
//           BottomNavigationBarItem(label:"Home",icon: Icon(Icons.home)),
//           BottomNavigationBarItem(label:"Home",icon: Icon(Icons.handyman)),
//           BottomNavigationBarItem(label:"Home",icon: Icon(Icons.production_quantity_limits)),
//           BottomNavigationBarItem(label:"Home",icon: Icon(Icons.person)),
//         ],
//       ),
//     );
//   }
// }
