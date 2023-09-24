import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manpower_management/screens/BookService.dart';


class ServicePage extends StatefulWidget {
  const ServicePage({Key? key}) : super(key: key);
  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  String _query = '';
  Future<List<QueryDocumentSnapshot>>? _futureServices;
  String _selected_title ='';
  String _selected_subtitle ='';
  String _selected_image_url ='';
  String _selected_price ='';
  List<DocumentSnapshot> TopServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _futureServices = _getServices('');
    getTopServices().then((value) => setState(() {
      _isLoading = false;
    }));
  }

  Future<void> getTopServices() async {
    QuerySnapshot querySnapshot =  await FirebaseFirestore.instance.collection('services').get();
    setState(() {
      TopServices = querySnapshot.docs;
      _isLoading = true;
    });
  }

  Future<List<QueryDocumentSnapshot>> _getServices(String query) async{
    final firestore = FirebaseFirestore.instance;
    final servicesRef = firestore.collection('services');
    final snapshot = await servicesRef.get();

    final services = snapshot.docs
        .where((service) =>
    service['name'].toLowerCase().contains(query.toLowerCase()) ||
        service['description'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return services;
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
                      _futureServices = _getServices(_query);
                    });
                  },
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                    hintText: "Search a service",
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              )
          ),

                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text('Top Services',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : CarouselSlider.builder(
                  itemCount: TopServices.length,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child:
                              Image.network(
                                TopServices[index]['image'],
                                height: 85.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    TopServices[index]['name'],
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // SizedBox(height: 5.0),
                                  // Text(
                                  //   TopServices[index]['description'],
                                  //   style: TextStyle(fontSize: 16.0),
                                  // ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    'Price: \₹${TopServices[index]['price']}',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                  },
                  options: CarouselOptions(
                    height: 172.0,
                    viewportFraction: 0.87,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 2),
                  ),
                ),
                Container(
                  child:Text('Other Services',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<QueryDocumentSnapshot>>(
                        future: _futureServices,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final services = snapshot.data ?? [];
                          return GridView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Set the number of columns here
                              mainAxisSpacing: 2,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: services.length,
                            itemBuilder: (BuildContext context, int index) {
                              final service = services[index];
                              final image = service['image'];
                              final name = service['name'];
                              final description = service['description'];
                              final price = service['price'];

                              return InkWell(
                                onTap: () {
                                  _selected_title = name;
                                  _selected_subtitle = description;
                                  _selected_image_url = image;
                                  _selected_price = price;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => BookServicePage(_selected_title.toString(),_selected_subtitle.toString(),_selected_image_url.toString(),_selected_price.toString())),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 5.0,
                                  ),
                                  child: Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 18 / 9,
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            SizedBox(height: 2.0),
                                            Text(
                                              description,
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Icon(Icons.shopping_basket),
                                                Text('\₹ $price'),
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