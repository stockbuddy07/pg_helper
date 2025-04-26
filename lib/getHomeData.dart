// ignore_for_file: camel_case_types

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// import 'PackageDetails.dart';

class get_home_data extends StatefulWidget {
  const get_home_data({super.key});

  @override
  State<get_home_data> createState() => _GetHomeDataState();
}

class _GetHomeDataState extends State<get_home_data> {
  late String packageImagePath;
  Map<dynamic, dynamic>? userData;
  Map<int, Map> userMap = {};
  List<Map> packages = [];
  late Map data2;

  Future<void> fetchUserData(String key, int index) async {
    DatabaseReference dbUserData = FirebaseDatabase.instance
        .ref()
        .child("ArogyaSair/tblHospital")
        .child(key);
    DatabaseEvent userDataEvent = await dbUserData.once();
    DataSnapshot userDataSnapshot = userDataEvent.snapshot;
    userData = userDataSnapshot.value as Map?;
    userMap[index] = {
      "Key": userDataSnapshot.key,
      "HospitalName": userData!["HospitalName"],
    };
    setState(() {});
  }

  Future<List<Map>> getPackagesData() async {
    DatabaseReference dbRef =
    FirebaseDatabase.instance.ref().child('ArogyaSair/tblPackages');
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value == null) {
      return [];
    }

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    if (packages.isEmpty) {
      values.forEach((key, value) async {
        if (value['Photo'] != null && value['Photo'].toString().isNotEmpty) {
          packages.add({
            'HospitalName': value['HospitalName'],
            'Photo': value["Photo"],
            'Key': key,
            'Duration': value["Duration"],
            'PackageName': value["PackageName"],
            'Include': value["Include"],
            'Price': value["Price"],
          });
        } else {
          packages.add({
            'HospitalName': value['HospitalName'],
            'Photo': 'ArogyaSair.png',
            'Key': key,
            'Duration': value["Duration"],
            'PackageName': value["PackageName"],
            'Include': value["Include"],
            'Price': value["Price"],
          });
        }
        fetchUserData(value["HospitalName"], packages.length - 1);
      });
      return packages;
    } else {
      return packages;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     SizedBox(
      //       // home page size
      //       height: MediaQuery.of(context).size.width * 0.47,
      //       width: double.infinity,
      //       child: FutureBuilder<List<Map>>(
      //         future: getPackagesData(),
      //         builder: (context, snapshot) {
      //           if (snapshot.hasError) {
      //             return Center(child: Text('Error: ${snapshot.error}'));
      //           } else if (snapshot.hasData && userMap.isNotEmpty) {
      //             if (packages.isNotEmpty) {
      //               return ListView.builder(
      //                 shrinkWrap: true,
      //                 scrollDirection: Axis.horizontal,
      //                 itemCount: packages.length,
      //                 itemBuilder: (context, index) {
      //                   return Column(
      //                     children: [
      //                       SizedBox(
      //                         // dots place
      //                         height: MediaQuery.of(context).size.width * 0.4,
      //                         width: MediaQuery.of(context).size.width,
      //                         child: Column(
      //                           children: [
      //                             CarouselSlider.builder(
      //                               itemCount: packages.length,
      //                               itemBuilder: (BuildContext context,
      //                                   int index, int realIndex) {
      //                                 data2 = userMap[index]!;
      //                                 if (packages[index]["Photo"] == "") {
      //                                   packageImagePath =
      //                                   "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/HospitalImage%2FDefaultProfileImage.png?alt=media";
      //                                 } else {
      //                                   packageImagePath =
      //                                   "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/PackageImage%2F${packages[index]["Photo"]}?alt=media";
      //                                 }
      //                                 return GestureDetector(
      //                                   onTap: () {
      //                                     if (packages[index]["Photo"] == "") {
      //                                       packageImagePath =
      //                                       "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/PackageImage%2FArogyaSair.png?alt=media";
      //                                     } else {
      //                                       packageImagePath =
      //                                       "https://firebasestorage.googleapis.com/v0/b/arogyasair-157e8.appspot.com/o/PackageImage%2F${packages[index]["Photo"]}?alt=media";
      //                                     }
      //                                     Navigator.push(
      //                                       context,
      //                                       MaterialPageRoute(
      //                                         builder: (context) =>
      //                                             PackageDetails(
      //                                                 PackageName:
      //                                                 packages[index]
      //                                                 ["PackageName"],
      //                                                 Price: packages[index]
      //                                                 ["Price"],
      //                                                 HospitalName:
      //                                                 data2['HospitalName'],
      //                                                 Duration: packages[index]
      //                                                 ["Duration"],
      //                                                 Include: packages[index]
      //                                                 ["Include"],
      //                                                 Image: packageImagePath,
      //                                                 // key
      //                                                 HospitalKey:
      //                                                 packages[index]
      //                                                 ["HospitalName"]),
      //                                       ),
      //                                     );
      //                                   },
      //                                   child: Card(
      //                                     child: Container(
      //                                       decoration: BoxDecoration(
      //                                         borderRadius:
      //                                         BorderRadius.circular(20),
      //                                         boxShadow: const [
      //                                           BoxShadow(
      //                                             color: Colors.white,
      //                                             spreadRadius: 1,
      //                                             offset: Offset(2, 2),
      //                                           ),
      //                                         ],
      //                                       ),
      //                                       child: Padding(
      //                                         padding: const EdgeInsets.only(
      //                                             left: 10, right: 10, top: 10),
      //                                         child: Row(
      //                                           crossAxisAlignment:
      //                                           CrossAxisAlignment.start,
      //                                           children: [
      //                                             Column(
      //                                               children: [
      //                                                 ClipRRect(
      //                                                   borderRadius:
      //                                                   BorderRadius
      //                                                       .circular(15),
      //                                                   // Adjust the value as needed
      //                                                   child: Image.network(
      //                                                     packageImagePath,
      //                                                     height: 120,
      //                                                     width: 120,
      //                                                     fit: BoxFit.fitHeight,
      //                                                   ),
      //                                                 ),
      //                                               ],
      //                                             ),
      //                                             Flexible(
      //                                               child: Column(
      //                                                 crossAxisAlignment:
      //                                                 CrossAxisAlignment
      //                                                     .start,
      //                                                 children: [
      //                                                   Padding(
      //                                                     padding:
      //                                                     const EdgeInsets
      //                                                         .only(
      //                                                         left: 10),
      //                                                     child: Text(
      //                                                       packages[index]
      //                                                       ["PackageName"],
      //                                                       style: const TextStyle(
      //                                                           color: Colors
      //                                                               .black,
      //                                                           fontWeight:
      //                                                           FontWeight
      //                                                               .bold,
      //                                                           fontSize: 17),
      //                                                     ),
      //                                                   ),
      //                                                   Padding(
      //                                                     padding:
      //                                                     const EdgeInsets
      //                                                         .only(
      //                                                         left: 10),
      //                                                     child: Text(
      //                                                       "₹ ${packages[index]["Price"]}",
      //                                                       style:
      //                                                       const TextStyle(
      //                                                           color: Colors
      //                                                               .black),
      //                                                     ),
      //                                                   ),
      //                                                   Padding(
      //                                                     padding:
      //                                                     const EdgeInsets
      //                                                         .only(
      //                                                         left: 10),
      //                                                     child: Text(
      //                                                       userMap[index]![
      //                                                       "HospitalName"],
      //                                                       style:
      //                                                       const TextStyle(
      //                                                           color: Colors
      //                                                               .black),
      //                                                     ),
      //                                                   ),
      //                                                 ],
      //                                               ),
      //                                             ),
      //                                           ],
      //                                         ),
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 );
      //                               },
      //                               options: CarouselOptions(
      //                                 // card size
      //                                 height:
      //                                 MediaQuery.of(context).size.width *
      //                                     0.4,
      //                                 //increase card size
      //                                 aspectRatio: 16 / 9,
      //                                 viewportFraction: 0.8,
      //                                 initialPage: 0,
      //                                 enableInfiniteScroll: true,
      //                                 reverse: false,
      //                                 autoPlay: true,
      //                                 autoPlayInterval:
      //                                 const Duration(seconds: 2),
      //                                 autoPlayAnimationDuration:
      //                                 const Duration(milliseconds: 800),
      //                                 autoPlayCurve: Curves.fastOutSlowIn,
      //                                 enlargeCenterPage: true,
      //                                 scrollDirection: Axis.horizontal,
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ],
      //                   );
      //                 },
      //               );
      //             } else {
      //               return const Center(child: Text('No hospitals found'));
      //             }
      //           } else {
      //             return const Center(child: CircularProgressIndicator());
      //           }
      //         },
      //       ),
      //     )
      //   ],
      // ),
    );
  }
}
