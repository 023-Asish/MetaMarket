import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manpower_management/screens/PlaceOrder.dart';

class Product_Cart extends StatefulWidget {
  @override
  _Product_CartState createState() => _Product_CartState();
}

class _Product_CartState extends State<Product_Cart> {
  List<Map<String, dynamic>> _cartProducts = [];
  double FinalTotalPrice=0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCartProducts();
  }

  void _fetchCartProducts() {
    FirebaseFirestore.instance
        .collection('cart')
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> cartProducts = [];
      querySnapshot.docs.forEach((doc) {
        cartProducts.add({
          'id': doc.id,
          'image': doc['image'],
          'name': doc['name'],
          'description': doc['description'],
          'price': doc['price'],
        });
      });
      setState(() {
        _cartProducts = cartProducts;
        _isLoading = false;
      });
    }).catchError((error) {
      print("Failed to fetch cart products: $error");
      setState(() {
        _isLoading = false; // set loading variable to false even if there's an error
      });
    });
  }

  void _removeFromCart(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('cart').doc(productId).delete();

      _fetchCartProducts();
    } catch (error) {
      print('Failed to remove product from cart: $error');

    }
  }

  double _calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var product in _cartProducts) {
      totalPrice += double.parse(product['price']);
    }
    FinalTotalPrice = totalPrice;
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.orange,
          title: Text('Cart'),
          toolbarHeight: 45,
        ),
        body:
        _isLoading ? // show loading indicator while data is being fetched
          Center(
            child: CircularProgressIndicator(),
          ) :
          _cartProducts.isNotEmpty?
              Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Image.network(
                                _cartProducts[index]['image'],
                                width: 110,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _cartProducts[index]['name'],
                                      style: TextStyle(fontSize: 19,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _cartProducts[index]['description'],
                                      style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(child: Text(
                                          'Price: \₹${_cartProducts[index]['price']}',
                                          style: TextStyle(fontSize: 17,
                                              fontWeight: FontWeight.w500),
                                        )),
                                        Expanded(child: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _removeFromCart(
                                                _cartProducts[index]['id']);
                                          },
                                        ))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(width: 1.0, color: Colors.grey)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '\₹ ${_calculateTotalPrice()}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      ElevatedButton(
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
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PlaceOrder(FinalTotalPrice)),
                          );
                        },
                        child: Text('Checkout'),
                      )
                    ],
                  ),
                )
              ]
          ):
              Center(
                child: Column(
                    children: [
                      Image.network('https://img.freepik.com/premium-vector/shopping-concepta-woman-goes-shopping-woman-is-pushing-empty-shopping-cartflat-vector-cartoon-character-illustration_77116-1411.jpg?w=2000',
                        fit: BoxFit.cover,
                      ),
                      Text('Your Cart is Empty',style: TextStyle(fontSize: 20),),
                    ],
                  ),
              )
    );
  }
}