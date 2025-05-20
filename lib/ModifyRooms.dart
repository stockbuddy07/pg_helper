import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// =================== Room Model ===================
class RoomRetrievalModel {
  final String key;
  final String roomNumber;
  final String roomSize;
  final String roomSharing;

  RoomRetrievalModel({
    required this.key,
    required this.roomNumber,
    required this.roomSize,
    required this.roomSharing,
  });

  factory RoomRetrievalModel.fromMap(String key, Map<dynamic, dynamic> data) {
    return RoomRetrievalModel(
      key: key,
      roomNumber: data['RoomNumber'] ?? '',
      roomSize: data['RoomSize'] ?? '',
      roomSharing: data['RoomSharing'] ?? '',
    );
  }
}

// =================== Bed Model ===================
class BedRetrievalModel {
  final String id;
  final String roomNumber;
  final String status;

  BedRetrievalModel({
    required this.id,
    required this.roomNumber,
    required this.status,
  });

  factory BedRetrievalModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return BedRetrievalModel(
      id: id,
      roomNumber: data['roomNumber'] ?? '',
      status: data['status'] ?? '',
    );
  }
}

// =================== Main Widget ===================
class ModifyRoomsPage extends StatefulWidget {
  const ModifyRoomsPage({Key? key}) : super(key: key);

  @override
  State<ModifyRoomsPage> createState() => _ModifyRoomsPageState();
}

class _ModifyRoomsPageState extends State<ModifyRoomsPage> {
  final _roomRef = FirebaseDatabase.instance.ref('PG_helper/tblRooms');
  final _bedRef = FirebaseDatabase.instance.ref('PG_helper/tblBeds');

  List<RoomRetrievalModel> _rooms = [];
  List<BedRetrievalModel> _beds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _roomRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      final rooms = data.entries
          .map((e) => RoomRetrievalModel.fromMap(e.key, Map.from(e.value)))
          .toList();
      setState(() => _rooms = rooms);
    });

    _bedRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      final beds = data.entries
          .map((e) => BedRetrievalModel.fromMap(e.key, Map.from(e.value)))
          .toList();
      setState(() => _beds = beds);
    });
  }

  // =================== Room Actions ===================
  void _editRoom(RoomRetrievalModel room) {
    final sizeCtrl = TextEditingController(text: room.roomSize);
    final sharingCtrl = TextEditingController(text: room.roomSharing);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Room ${room.roomNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sizeCtrl, decoration: InputDecoration(labelText: 'Room Size')),
            TextField(controller: sharingCtrl, decoration: InputDecoration(labelText: 'Room Sharing')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _roomRef.child(room.key).update({
                'RoomSize': sizeCtrl.text.trim(),
                'RoomSharing': sharingCtrl.text.trim(),
              });
              Navigator.pop(context);
              sizeCtrl.dispose();
              sharingCtrl.dispose();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room updated')));
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteRoom(String key) async {
    await _roomRef.child(key).remove();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room deleted')));
  }

  // =================== Bed Actions ===================
  void _editBed(BedRetrievalModel bed) {
    final statusCtrl = TextEditingController(text: bed.status);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Bed ${bed.id}'),
        content: TextField(controller: statusCtrl, decoration: InputDecoration(labelText: 'Status')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _bedRef.child(bed.id).update({
                'status': statusCtrl.text.trim(),
              });
              Navigator.pop(context);
              statusCtrl.dispose();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bed updated')));
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteBed(String id) async {
    await _bedRef.child(id).remove();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bed deleted')));
  }

  // =================== UI ===================
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
        itemBuilder: (_, index) {
          final room = _rooms[index];
          final roomBeds = _beds.where((b) => b.roomNumber == room.roomNumber).toList();

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Room No: ${room.roomNumber}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("Size: ${room.roomSize}"),
                  Text("Sharing: ${room.roomSharing}"),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),

                        style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                        onPressed: () => _editRoom(room),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.delete),
                        label: Text('Delete'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () => _deleteRoom(room.key),
                      ),
                    ],
                  ),
                  if (roomBeds.isNotEmpty) ...[
                    Divider(height: 30),
                    Text("Beds", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...roomBeds.map((bed) => ListTile(
                      title: Text("Bed ID: ${bed.id}"),
                      subtitle: Text("Status: ${bed.status}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editBed(bed),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteBed(bed.id),
                          ),
                        ],
                      ),
                    )),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
