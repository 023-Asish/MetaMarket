import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manpower_management/screens/Product_Cart.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _query = '';
  Future<List<QueryDocumentSnapshot>>? _SelectedProduct;

  List<Map<String, dynamic>> _products = [];
  // Future<List<QueryDocumentSnapshot>>? _products;
  final _scrollController = ScrollController();
  final List<String> imagePaths=[
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlSOLNlmnb44__3Zv9iFw8CzWu5Dht1YdbIg&usqp=CAU',
    'https://img.freepik.com/premium-vector/online-shopping-banner-ecommerce-sales-digital-marketing_126283-2357.jpg?w=2000',
    'https://img.freepik.com/free-vector/flat-horizontal-sale-banner-template-with-photo_23-2149000923.jpg?w=2000',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzt7vy5hRlSXchpL2nXOdu3SeLJivwu19L0PTaJ_baaItkWGCdD3qLUdKu-vqlJbUMvBE&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGcl9wQDkkrFOJ2YHDQxiI9uq2MMxcM3CrvA&usqp=CAU'
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      _fetchProducts();
    });
    _SelectedProduct = _getProduct('');

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Add your logic here for loading more data or fetching more items
        _scrollController.animateTo(0,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  Future<List<QueryDocumentSnapshot>> _getProduct(String query) async{
    final firestore = FirebaseFirestore.instance;
    final productsRef = firestore.collection('products');
    final snapshot = await productsRef.get();

    final products = snapshot.docs
        .where((product) =>
    product['name'].toLowerCase().contains(query.toLowerCase()) || product['description'].toLowerCase().contains(query.toLowerCase())).toList();

    List<Map<String, dynamic>> listOfMaps = [];
    products.forEach((documentSnapshot) {
      Map<String, dynamic> data = documentSnapshot.data();
      listOfMaps.add(data);
    });
    _products = listOfMaps;
    return products;
  }

  void _fetchProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<Map<String, dynamic>> products = [];
      querySnapshot.docs.forEach((doc) {
        products.add({
          'id': doc.id,
          'image': doc['image'],
          'name': doc['name'],
          'description': doc['description'],
          'price': doc['price'],
          // 'rating': doc['rating'],
        });
      });
      setState(() {
        _products = products;
      });
    }).catchError((error) {
      print("Failed to fetch products: $error");
    });
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    try {
      await FirebaseFirestore.instance.collection('cart').add({
        'image': product['image'],
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
      });
    } catch (error) {
      print('Failed to add product to cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Theme(
              data: Theme.of(context).copyWith(splashColor: Colors.white),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _query = value;
                    _SelectedProduct = _getProduct(_query);
                  });
                },
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  hintText: "Search a Product",
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
          ),

          CarouselSlider.builder(
            itemCount: imagePaths.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        child:
                        Image.network(
                          imagePaths[index],
                          height: 90.0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                );
            },
            options: CarouselOptions(
              height: 110.0,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 2),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _SelectedProduct,
              builder: (BuildContext context,
                  AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data ?? [];

                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 65000),
                    curve: Curves.linear,
                  );
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = products[index];
                    final image = product['image'];
                    final name = product['name'];
                    final description = product['description'];
                    final price = product['price'];

                    return
                      Card(
                        child:
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child:
                          Row(
                            children: [
                              Image.network(
                                image,
                                width: 150,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      description,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),

                                    SizedBox(height: 5),
                                    Text(
                                      'Price: \₹${price}',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.yellow),
                                        // SizedBox(width: 5),
                                        // Text('${product['rating']}',),
                                        Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.shopping_cart),
                                          onPressed: () {
                                            addToCart(_products[index]);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => Product_Cart()),
                                            );
                                          },
                                        ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}