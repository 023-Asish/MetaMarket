import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:manpower_management/screens/PaymentPage.dart';
import 'package:pay/pay.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class PlaceOrder extends StatefulWidget {
  double FinalTotalPrice=0;
  PlaceOrder(this.FinalTotalPrice);
  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  late Razorpay _razorpay;
  String ?_email;
  String ?_phoneNumber;
  String ?_address;
  double _subTotal = 0.0; // sample sub total
  double _deliveryCharge = 40.0; // sample delivery charge

  // method to calculate total
  // double _getTotal() {
  //   return ;
  // }

  // void addPost(String address, String date, String time, String offer, String price) {
  //   FirebaseFirestore.instance.collection('service_booking').add({
  //     'userEmail': FirebaseAuth.instance.currentUser?.email,
  //     'serviceTitle': widget.title,
  //     'userAddress': address,
  //     'selectedDate': date,
  //     'selectedTime': time,
  //     'selectedOffer': offer,
  //     'price': price,
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // Initialize Razorpay instance
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle successful payment
    print("Payment successful");
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print("Payment failed");
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet payment
    print("External wallet payment");
  }
  void openCheckout() {
    var options = {
      'key': 'rzp_test_jNKUEly55tcDGz',
      'amount': ((widget.FinalTotalPrice + _deliveryCharge)*100).toString(), // amount in paise
      'name': 'Manpower Management',
      'description': 'My Product',
      'timeout':300,
      'prefill': {'contact': '9999999999', 'email': '${FirebaseAuth.instance.currentUser?.email}'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      // debugPrint(e);
    }
  }
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Order"),
          content: Text("Click on Order Now"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Order Now"),
              onPressed: () {
                // Add post to database
                // addPost(_addressController.text, selectedDate, selectedTime, selectedOffer, widget.price);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Order Placed successfully!"),
                  ),
                );

                // Close confirmation dialog
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // Navigate back to previous screen
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: Text('Place Order'),
        toolbarHeight: 45,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Image.network('https://blog.uber-cdn.com/cdn-cgi/image/width=2160,quality=80,onerror=redirect,format=auto/wp-content/uploads/2020/06/Screen-Shot-2020-06-10-at-12.48.20-PM-2.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),
                  ),
                  Text('${FirebaseAuth.instance.currentUser?.email}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: TextField(
                onChanged: (value) => _phoneNumber = value,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Enter your Phone number',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17.0,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            // Text('Address',
            //   style: TextStyle(
            //     fontWeight: FontWeight.w500,
            //     fontSize: 18.0,
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: TextField(
                onChanged: (value) => _address = value,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Enter your address',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17.0,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Order Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(color: Colors.black,thickness: 1.5),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sub Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17.0,
                    ),
                  ),
                  Text('\₹${widget.FinalTotalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Charge',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17.0,
                    ),
                  ),
                  Text('\₹${_deliveryCharge.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(color: Colors.black,thickness: 1.5),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                    ),
                  ),
                  Text('\₹${(widget.FinalTotalPrice + _deliveryCharge).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height:4.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: Text('Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style:ElevatedButton.styleFrom(
                        // minimumSize: const Size.fromHeight(40),
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
                      onPressed: (){
                        _showConfirmationDialog(context);
                      },
                      child: Text('Cash on Delivery',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  // Expanded(
                  //     child: ElevatedButton(
                  //       onPressed: (){
                  //
                  //       },
                  //       child:Text('Pay Now',
                  //         // style: TextStyle(
                  //         //   fontWeight: FontWeight.w500,
                  //         //   fontSize: 18.0,
                  //         //   backgroundColor: Colors.black,
                  //         // ),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.black,
                  //         ),
                  //       ),
                  //     ),
                  // ),
                  Expanded(
                    child: ElevatedButton(
                      style:ElevatedButton.styleFrom(
                        // minimumSize: const Size.fromHeight(40),
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
                      onPressed: (){
                        openCheckout();
                      },
                      child: Text('Pay now',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
