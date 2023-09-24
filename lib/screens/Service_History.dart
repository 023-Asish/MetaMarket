import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ServiceHistory extends StatefulWidget {
  @override
  _ServiceHistoryState createState() => _ServiceHistoryState();
}

class _ServiceHistoryState extends State<ServiceHistory> {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  Razorpay razorpay = Razorpay();

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle payment success
    print("Payment successful");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print("Payment failed");
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet response
    print("External wallet payment");
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_jNKUEly55tcDGz',
      'amount': 10 * 100,
      'name': 'Manpower Management',
      'description': 'Service Payment',
      'timeout':300,
      'prefill': {'contact': '9999999999', 'email': '${FirebaseAuth.instance.currentUser?.email}'},      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service History"),
        // centerTitle: true,
        backgroundColor: Colors.orange,
        toolbarHeight: 42,
      ),
      body: currentUserEmail == null
            ? Center(
              child: Text('Please login to view your service history'),
            )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_booking')
            .where('userEmail', isEqualTo: currentUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final serviceData = snapshot.data!.docs[index];
              return Card(
                child:Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 10),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceData['serviceTitle'], style: TextStyle(fontSize: 18),),
                      Text("service Id: ${serviceData['serviceId']}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status: ${serviceData['status']}"),
                          Text("Worker: ${serviceData['worker']}"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(serviceData['selectedDate']))}"),
                          Text("Time: ${serviceData['selectedTime']}"),
                        ],
                      ),
                      Text("Address: ${serviceData['userAddress']}"),
                      Text("Total Amount: ₹${serviceData['price']}"),
                      ElevatedButton(
                          onPressed: (){
                            openCheckout();
                          },
                          child: Text('Pay Now'),
                        style:ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 8.0,
                            top: 4.0,
                          ),
                          backgroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                color: Colors.black38,
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                )
              );
            },
          );
        },
      ),
    );
  }
}