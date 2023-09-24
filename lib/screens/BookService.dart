import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:manpower_management/screens/TempService.dart';
import 'package:uuid/uuid.dart';


class BookServicePage extends StatefulWidget {
  String title ='';
  String subTitle ='';
  String image_url ='';
  String price='';
  BookServicePage(this.title,this.subTitle,this.image_url,this.price);
  @override
  _BookServicePageState createState() => _BookServicePageState();
}

class _BookServicePageState extends State<BookServicePage> {
  String selectedDate = 'Select Date';
  String selectedTime = 'Select Time';
  String selectedRepeat = 'No Repeat';
  List<String> repeatOptions = ['No Repeat', 'Weekly', 'Monthly'];
  double expectedPrice = 400.0;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked.toString();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked.format(context);
      });
    }
  }

  List<Map<String, dynamic>> offers = [
    {'name': 'Seasonal', 'description': 'Get ready for the season with our amazing seasonal offers!', 'discount': '15%'},
    {'name': 'Yearly', 'description': 'Looking for year-round savings? Check out our incredible yearly offers! From exclusive discounts to VIP perks, we have got you covered.', 'discount': '20%'},
    {'name': 'Monthly', 'description': "Don't miss out on our monthly offers! Enjoy amazing discounts, freebies, and more every month. Subscribe now to stay updated and save big.", 'discount': '10%'},
    {'name': 'Weekly', 'description': "Get more for less with our weekly offers! From groceries to electronics, we've got you covered with unbeatable prices.", 'discount': '5%'},
    {'name': 'No Repeat', 'description': 'select no packages', 'discount': '0%'},
  ];
  String selectedOffer='Select Package';
  void _selectOffer(String offer) {
    setState(() {
      selectedOffer = offer.toString();
    });
    Navigator.pop(context);
  }
  void _showOffersList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Available Packages'),
            content: SingleChildScrollView(
              child: Column(
                children: offers
                    .map((offer) => ListTile(
                  title: Text(offer['name']),
                  subtitle: Text(offer['description']),
                  trailing: Text(offer['discount']),
                  onTap: () => _selectOffer(offer['name']),
                ))
                    .toList(),
              ),
            ),
          );
        });
  }

  void addPost(String address, String date, String time, String offer, String price) {
    var uuid = Uuid();
    String serviceId = uuid.v4();
    FirebaseFirestore.instance.collection('service_booking').add({
      'serviceId': serviceId,
      'userEmail': FirebaseAuth.instance.currentUser?.email,
      'serviceTitle': widget.title,
      'userAddress': address,
      'selectedDate': date,
      'selectedTime': time,
      'price': price,
      'status': 'active',
      'worker': 'not assigned',
      'canceled':false,
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Booking"),
          content: Text("Are you sure you want to book this service?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Book Now"),
              onPressed: () async{
                // Add post to database
                addPost(_addressController.text, selectedDate, selectedTime, selectedOffer, widget.price);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Service booked successfully!"),
                  ),
                );
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  TextEditingController _addressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: Text('Book Your Service'),
        toolbarHeight: 45,
      ),
      body:SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                  child: Image.network(widget.image_url,
                    fit: BoxFit.cover,
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.subTitle}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(height: 16.0),

                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Enter your address',
                          border: OutlineInputBorder(),
                        ),
                      ),


                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: Text(selectedDate),
                          ),
                          SizedBox(width: 16.0),
                          ElevatedButton(
                            onPressed: () => _selectTime(context),
                            child: Text(selectedTime),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),


                      ElevatedButton(
                        onPressed: () => _showOffersList(context),
                        child: Text(selectedOffer),
                      ),

                      SizedBox(height: 16.0),
                      Text(
                        'Expected Price:    \₹${widget.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,

                        ),
                      ),
                      SizedBox(height: 16.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: ()=> _showConfirmationDialog(context),
                          child: Text('Book Now'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(horizontal: 133, vertical: 10),
                              textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
              ),
            ],
          ),
      ),
    );
  }
}