import 'package:flutter/material.dart';
import 'RoomsBySharingPage.dart';

class ShowRoomsPage extends StatelessWidget {
  final List<String> sharingOptions = ['2', '3', '4', '5'];

  final List<Color> cardColors = [
    Color(0xFF80DEEA), // Light Cyan
    Color(0xFF81C784), // Light Green
    Color(0xFFFFAB91), // Soft Orange
    Color(0xFFCE93D8), // Light Purple
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Room Sharing"),
        backgroundColor: const Color(0xff12d3c6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: sharingOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final sharing = sharingOptions[index];
            final cardColor = cardColors[index % cardColors.length];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomsBySharingPage(sharing: sharing),
                  ),
                );
              },
              child: Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "$sharing Sharing",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// backup code
// // ignore_for_file: file_names
//
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// class ShowRoomsPage extends StatefulWidget {
//   @override
//   _ShowRoomsPageState createState() => _ShowRoomsPageState();
// }
//
// class _ShowRoomsPageState extends State<ShowRoomsPage> {
//   final DatabaseReference _roomRef =
//   FirebaseDatabase.instance.ref().child('PG_helper/add_room_beds');
//
//   Map<int, List<Map<String, dynamic>>> _groupedRooms = {};
//   int _totalBeds = 0;
//   int _totalAvailableBeds = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchRooms();
//   }
//
//   void _fetchRooms() {
//     _roomRef.onValue.listen((event) {
//       final data = event.snapshot.value;
//       Map<int, List<Map<String, dynamic>>> grouped = {};
//       int totalBeds = 0;
//       int totalAvailableBeds = 0;
//
//       if (data != null) {
//         final rooms = Map<String, dynamic>.from(data as Map);
//         rooms.forEach((key, value) {
//           final room = Map<String, dynamic>.from(value);
//           final int beds = (room['beds'] ?? 0);
//           final int available = (room['availableBeds'] ?? 0);
//
//           if (!grouped.containsKey(beds)) {
//             grouped[beds] = [];
//           }
//
//           grouped[beds]!.add({
//             'roomNumber': room['roomNumber'],
//             'beds': beds,
//             'availableBeds': available,
//             'roomSize': room['roomSize'] ?? '',
//           });
//
//           totalBeds += beds;
//           totalAvailableBeds += available;
//         });
//       }
//
//       setState(() {
//         _groupedRooms = grouped;
//         _totalBeds = totalBeds;
//         _totalAvailableBeds = totalAvailableBeds;
//       });
//     });
//   }
//
//   List<PieChartSectionData> _buildPieChartSections() {
//     final List<PieChartSectionData> sections = [];
//
//     _groupedRooms.forEach((beds, rooms) {
//       final bedCount = beds * rooms.length;
//       final percentage = (_totalBeds == 0) ? 0 : (bedCount / _totalBeds) * 100;
//
//       sections.add(PieChartSectionData(
//         color: _getColorForBeds(beds),
//         value: bedCount.toDouble(),
//         title: "$beds Bed\n${percentage.toStringAsFixed(1)}%",
//         radius: 60,
//         titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//       ));
//     });
//
//     return sections;
//   }
//
//   Color _getColorForBeds(int beds) {
//     switch (beds) {
//       case 1:
//         return Colors.teal;
//       case 2:
//         return Colors.blue;
//       case 3:
//         return Colors.orange;
//       case 4:
//         return Colors.purple;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Rooms by Sharing"),
//         backgroundColor: Color(0xff12d3c6),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _groupedRooms.isEmpty
//             ? Center(child: Text("No rooms found"))
//             : ListView(
//           children: [
//             Text(
//               "Total Beds: $_totalBeds | Available: $_totalAvailableBeds",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               color: Colors.green.shade50,
//               elevation: 4,
//               margin: EdgeInsets.symmetric(vertical: 10),
//               child: ListTile(
//                 leading: Icon(Icons.check_circle, color: Colors.green),
//                 title: Text(
//                   "Available Beds",
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//                 subtitle: Text(
//                     "$_totalAvailableBeds available out of $_totalBeds"),
//               ),
//             ),
//             SizedBox(height: 20),
//             AspectRatio(
//               aspectRatio: 1.3,
//               child: PieChart(
//                 PieChartData(
//                   sections: _buildPieChartSections(),
//                   centerSpaceRadius: 40,
//                   sectionsSpace: 2,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             ..._groupedRooms.entries.map((entry) {
//               int beds = entry.key;
//               List<Map<String, dynamic>> rooms = entry.value;
//
//               return Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 4,
//                 margin: EdgeInsets.symmetric(vertical: 10),
//                 child: ListTile(
//                   title: Text(
//                     "$beds Sharing Bed",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                   subtitle: Text("${rooms.length} room(s) available"),
//                   leading: Icon(Icons.bed, color: Colors.teal),
//                   trailing: Icon(Icons.arrow_forward_ios),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => RoomListPage(
//                           beds: beds,
//                           rooms: rooms,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class RoomListPage extends StatelessWidget {
//   final int beds;
//   final List<Map<String, dynamic>> rooms;
//
//   const RoomListPage({required this.beds, required this.rooms, Key? key})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("$beds Sharing Rooms"),
//         backgroundColor: Color(0xff12d3c6),
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: rooms.length,
//         itemBuilder: (context, index) {
//           final room = rooms[index];
//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 3,
//             margin: EdgeInsets.only(bottom: 12),
//             child: ListTile(
//               leading: Icon(Icons.meeting_room, color: Colors.deepPurple),
//               title: Text("Room No: ${room['roomNumber']}"),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Size: ${room['roomSize'] ?? 'N/A'}"),
//                   Text(
//                       "Beds: ${room['beds']} | Available: ${room['availableBeds']}"),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

