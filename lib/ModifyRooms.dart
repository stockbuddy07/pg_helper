// Your existing imports
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import '../models/RoomRetrievalModel.dart';
import '../models/BedRetrievalModel.dart';

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

  StreamSubscription<DatabaseEvent>? _roomSub;
  StreamSubscription<DatabaseEvent>? _bedSub;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _roomSub = _roomRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) return;

      if (value is Map) {
        final rooms = value.entries
            .map((e) => RoomRetrievalModel.fromMap(e.key, Map<String, dynamic>.from(e.value)))
            .toList();
        if (mounted) setState(() => _rooms = rooms);
      }
    });

    _bedSub = _bedRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) return;

      if (value is Map) {
        final beds = value.entries
            .map((e) => BedRetrievalModel.fromMap(e.key, Map<String, dynamic>.from(e.value)))
            .toList();
        if (mounted) setState(() => _beds = beds);
      }
    });
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _bedSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _editRoom(RoomRetrievalModel room) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditRoomDialog(room: room, roomRef: _roomRef),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room updated.')),
      );
    }
  }

  void _deleteRoom(String key) async {
    final roomSnapshot = await _roomRef.child(key).get();
    if (!roomSnapshot.exists) return;

    final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);
    final roomNumber = roomData['RoomNumber'];

    final userRef = FirebaseDatabase.instance.ref('PG_helper/tblUser');
    final userSnapshot = await userRef.get();

    List<String> usersInRoom = [];

    if (userSnapshot.exists) {
      final userMap = Map<String, dynamic>.from(userSnapshot.value as Map);
      for (final entry in userMap.entries) {
        final userData = Map<String, dynamic>.from(entry.value);
        if (userData['RoomNumber'] == roomNumber) {
          final name = '${userData['FirstName'] ?? ''} ${userData['LastName'] ?? ''}';
          final contact = userData['ContactNumber'] ?? '';
          final username = userData['Username'] ?? '';
          usersInRoom.add("👤 $name\n📱 $contact\n🔑 $username");
        }
      }
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room?'),
        content: usersInRoom.isEmpty
            ? const Text('No users are assigned to this room. Proceed with deletion?')
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Following users are assigned to this room:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...usersInRoom.map((info) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(info),
            )),
            const Divider(),
            const Text('Are you sure you want to delete this room?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Step 1: Unassign users from this room
        if (userSnapshot.exists) {
          final userMap = Map<String, dynamic>.from(userSnapshot.value as Map);
          for (final entry in userMap.entries) {
            final userKey = entry.key;
            final userData = Map<String, dynamic>.from(entry.value);
            if (userData['RoomNumber'] == roomNumber) {
              await userRef.child(userKey).update({
                'BedStatus': 'unallocated',
              });
              await userRef.child(userKey).child('RoomNumber').remove();
              await userRef.child(userKey).child('Sharing').remove();
              await userRef.child(userKey).child('BedNumber').remove();
            }
          }
        }

        // Step 2: Delete the room from tblRooms
        await _roomRef.child(key).remove();

        // Step 3: Delete beds from tblBeds that belong to this room
        final bedsSnapshot = await _bedRef.get();
        if (bedsSnapshot.exists) {
          final bedsMap = Map<String, dynamic>.from(bedsSnapshot.value as Map);
          for (final bedGroupEntry in bedsMap.entries) {
            final groupKey = bedGroupEntry.key;
            final groupData = Map<String, dynamic>.from(bedGroupEntry.value);

            // Check if any bed in the group has roomNumber == deleted room
            final hasRoom = groupData.values.any((bed) =>
            bed is Map &&
                bed.containsKey('roomNumber') &&
                bed['roomNumber'].toString() == roomNumber.toString());

            if (hasRoom) {
              await _bedRef.child(groupKey).remove();
            }
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  List<RoomRetrievalModel> _filteredRooms() {
    if (_searchQuery.isEmpty) return _rooms;
    return _rooms
        .where((room) => room.roomNumber.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Modify Rooms",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Room Number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: _rooms.isEmpty
                ? const Center(child: Text('No rooms found'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredRooms().length,
              itemBuilder: (_, index) {
                final room = _filteredRooms()[index];
                final roomBeds = _beds.where((b) => b.roomNumber == room.roomNumber).toList();

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Room No: ${room.roomNumber}",
                          style: TextStyle(fontSize: 18 * textScale, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text("Size: ${room.roomSize}", style: TextStyle(fontSize: 14 * textScale)),
                        Text("Sharing: ${room.roomSharing}", style: TextStyle(fontSize: 14 * textScale)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                              onPressed: () => _editRoom(room),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => _deleteRoom(room.key),
                            ),
                          ],
                        ),
                        if (roomBeds.isNotEmpty) ...[
                          const Divider(height: 30),
                          const Text("Beds", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...roomBeds.map((bed) => ListTile(
                            title: Text("Bed ID: ${bed.id}"),
                            subtitle: Text("Status: ${bed.status}"),
                            trailing: const Icon(Icons.bed_outlined, color: Colors.grey),
                          )),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EditRoomDialog extends StatefulWidget {
  final RoomRetrievalModel room;
  final DatabaseReference roomRef;

  const _EditRoomDialog({required this.room, required this.roomRef});

  @override
  State<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<_EditRoomDialog> {
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _sharingCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _sizeCtrl = TextEditingController(text: widget.room.roomSize);
    _sharingCtrl = TextEditingController(text: widget.room.roomSharing);
  }

  @override
  void dispose() {
    _sizeCtrl.dispose();
    _sharingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Room"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _sizeCtrl,
            decoration: const InputDecoration(labelText: "Room Size"),
          ),
          TextField(
            controller: _sharingCtrl,
            decoration: const InputDecoration(labelText: "Sharing"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
            setState(() => _isSaving = true);
            await widget.roomRef.child(widget.room.key).update({
              'RoomSize': _sizeCtrl.text.trim(),
              'RoomSharing': _sharingCtrl.text.trim(),
            });
            setState(() => _isSaving = false);
            if (mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}