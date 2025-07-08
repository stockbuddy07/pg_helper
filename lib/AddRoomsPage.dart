// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'RoomDetailsPage.dart';
import 'models/RoomRetrievalModel.dart';
import 'models/RoomFormModel.dart';

class AddRoomPage extends StatefulWidget {
  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final _roomController = TextEditingController();
  final _sizeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedSharing;

  final DatabaseReference _roomRef = FirebaseDatabase.instance.ref().child('PG_helper/tblRooms');
  List<RoomRetrievalModel> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    _roomRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<RoomRetrievalModel> loadedRooms = [];
        data.forEach((key, value) {
          loadedRooms.add(RoomRetrievalModel.fromMap(key, value));
        });
        loadedRooms.sort((a, b) => a.key.compareTo(b.key));
        setState(() {
          _rooms = loadedRooms;
        });
      } else {
        setState(() {
          _rooms = [];
        });
      }
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedSharing == null) return;

    final formData = RoomFormModel(
      roomNumber: _roomController.text.trim(),
      roomSize: _sizeController.text.trim(),
      roomSharing: _selectedSharing!,
    );

    final existingRoom = _rooms.firstWhere(
          (room) => room.roomNumber == formData.roomNumber,
      orElse: () => RoomRetrievalModel(key: '', roomNumber: '', roomSize: '', roomSharing: ''),
    );

    final roomExists = existingRoom.key.isNotEmpty;

    if (roomExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Room number already used"),
          backgroundColor: Color(0xD72A8AEA), // Blue color
        ),
      );
      return;
    }

    final newRoomKey = _roomRef.push().key;
    await _roomRef.child(newRoomKey!).set(formData.toMap());

    final bedRef = FirebaseDatabase.instance.ref().child('PG_helper/tblBeds/$newRoomKey');
    for (int i = 1; i <= int.parse(formData.roomSharing); i++) {
      await bedRef.child('bed$i').set({
        'status': 'available',
        'roomNumber': formData.roomNumber,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Room added successfully"),
        backgroundColor: Color(0xD72A8AEA), // Blue color
      ),
    );

    _roomController.clear();
    _sizeController.clear();
    setState(() {
      _selectedSharing = null;
    });
  }

  void _navigateToRoomDetails(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomDetailPage(roomId: roomId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // back button color
        title: const Text(
          "Add Room",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _roomController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Room Number",
                      labelStyle: TextStyle(color: Color(0xD72A8AEA)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xD72A8AEA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xD72A8AEA)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Enter room number" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _sizeController,
                    decoration: InputDecoration(
                      labelText: "Size of Room (e.g. 12x10 ft)",
                      labelStyle: TextStyle(color: Color(0xD72A8AEA)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xD72A8AEA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xD72A8AEA)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value == null || value.isEmpty ? "Enter room size" : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSharing,
                    items: ['2', '3', '4', '5']
                        .map((val) => DropdownMenuItem(
                      value: val,
                      child: Text("$val Sharing", style: TextStyle(color: Colors.black)),
                    ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSharing = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Sharing",
                      labelStyle: TextStyle(color: Color(0xD72A8AEA)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xD72A8AEA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xD72A8AEA)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: Colors.black),
                    validator: (val) => val == null ? "Select sharing" : null,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text("Add Room", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xD72A8AEA), // Blue button
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            _rooms.isEmpty
                ? Center(child: Text("No rooms added yet.", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 16),
              physics: NeverScrollableScrollPhysics(),
              itemCount: _rooms.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 2,
              ),
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return GestureDetector(
                  onTap: () => _navigateToRoomDetails(room.key),
                  child: Card(
                    color: Colors.white, // White card background
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Color(0xD72A8AEA).withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bed, size: 36, color: Color(0xD72A8AEA)), // Blue icon
                          SizedBox(height: 8),
                          Text(
                            "Room No: ${room.roomNumber}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xD72A8AEA)), // Blue text
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}