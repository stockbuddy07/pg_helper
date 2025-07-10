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
      _showSnackBar("Room number already used");
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

    _showSnackBar("Room added successfully");

    _roomController.clear();
    _sizeController.clear();
    setState(() {
      _selectedSharing = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xD72A8AEA),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToRoomDetails(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomDetailPage(roomId: roomId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Color(0xD72A8AEA);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Add Room", style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Add Room Form - without Card
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 16),

                _buildTextField("Room Number", _roomController, accentColor, TextInputType.number),
                SizedBox(height: 16),

                _buildTextField("Size of Room (e.g. 12x10 ft)", _sizeController, accentColor, TextInputType.text),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedSharing,
                  items: ['2', '3', '4', '5']
                      .map((val) => DropdownMenuItem(value: val, child: Text("$val Sharing")))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSharing = val),
                  decoration: _inputDecoration("Sharing", accentColor),
                  validator: (val) => val == null ? "Select sharing" : null,
                ),

                SizedBox(height: 30),

                // Custom Add Room Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text("Add Room", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      backgroundColor: accentColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),


          SizedBox(height: 32),
          Text("All Rooms", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),

          _rooms.isEmpty
              ? Center(child: Text("No rooms added yet.", style: TextStyle(color: Colors.white)))
              : GridView.builder(
            shrinkWrap: true,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.king_bed, size: 32, color: accentColor),
                        SizedBox(height: 8),
                        Text("Room No: ${room.roomNumber}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 4),
                        Text("${room.roomSharing}-Sharing",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Color accent, TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: _inputDecoration(label, accent),
      validator: (value) => value == null || value.isEmpty ? "Enter $label" : null,
    );
  }

  InputDecoration _inputDecoration(String label, Color accent) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accent),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accent)),
    );
  }
}
