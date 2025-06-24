import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ModifyRoomsPage extends StatefulWidget {
  const ModifyRoomsPage({Key? key}) : super(key: key);

  @override
  State<ModifyRoomsPage> createState() => _ModifyRoomsPageState();
}

class _ModifyRoomsPageState extends State<ModifyRoomsPage> {
  final DatabaseReference _roomRef =
  FirebaseDatabase.instance.ref().child('PG_helper/add_room_beds');

  List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  void _fetchRooms() {
    _roomRef.onValue.listen((event) {
      final data = event.snapshot.value;
      List<Map<String, dynamic>> roomsList = [];

      if (data != null) {
        final rooms = Map<String, dynamic>.from(data as Map);
        rooms.forEach((key, value) {
          final room = Map<String, dynamic>.from(value);
          room['key'] = key; // Save Firebase key
          roomsList.add(room);
        });
      }

      setState(() {
        _rooms = roomsList;
      });
    });
  }

  void _deleteRoom(String key) async {
    await _roomRef.child(key).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Room deleted')),
    );
  }

  void _editRoomDialog(Map<String, dynamic> room) {
    final TextEditingController roomNumberController =
    TextEditingController(text: room['roomNumber']);
    final TextEditingController bedsController =
    TextEditingController(text: room['beds'].toString());
    final TextEditingController availableBedsController =
    TextEditingController(text: room['availableBeds'].toString());
    final TextEditingController sizeController =
    TextEditingController(text: room['roomSize']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Room ${room['roomNumber']}'),
        content: SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomNumberController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Room Number (read-only)',
                ),
              ),
              TextField(
                controller: bedsController,
                decoration: InputDecoration(labelText: 'Beds'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: availableBedsController,
                decoration: InputDecoration(labelText: 'Available Beds'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sizeController,
                decoration: InputDecoration(labelText: 'Room Size'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _roomRef.child(room['key']).update({
                'beds': int.tryParse(bedsController.text) ?? 0,
                'availableBeds': int.tryParse(availableBedsController.text) ?? 0,
                'roomSize': sizeController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Room updated')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Rooms'),
        backgroundColor: Color(0xff12d3c6),
      ),
      body: _rooms.isEmpty
          ? Center(child: Text('No rooms found'))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.meeting_room, color: Colors.blueAccent),
              title: Text("Room No: ${room['roomNumber']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Size: ${room['roomSize']}"),
                  Text("Beds: ${room['beds']} | Available: ${room['availableBeds']}"),
                ],
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editRoomDialog(room),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRoom(room['key']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
