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
    super.dispose();
  }

  Future<void> _editRoom(RoomRetrievalModel room) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditRoomDialog(room: room, roomRef: _roomRef),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room updated.')),
      );
    }
  }

  Future<void> _editBed(BedRetrievalModel bed) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditBedDialog(bed: bed, bedRef: _bedRef),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bed updated')));
    }
  }

  void _deleteRoom(String key) async {
    await _roomRef.child(key).remove();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted')));
  }

  void _deleteBed(String id) async {
    await _bedRef.child(id).remove();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bed deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // back button color
        title: const Text(
          "Modify Rooms",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: _rooms.isEmpty
          ? const Center(child: Text('No rooms found'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length,
        itemBuilder: (_, index) {
          final room = _rooms[index];
          final roomBeds = _beds.where((b) => b.roomNumber == room.roomNumber).toList();

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Room No: ${room.roomNumber}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Size: ${room.roomSize}"),
                  Text("Sharing: ${room.roomSharing}"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                        onPressed: () => _editRoom(room),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editBed(bed),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final roomNumber = widget.room.roomNumber;
      final oldSharing = int.tryParse(widget.room.roomSharing) ?? 0;
      final newSharing = int.tryParse(_sharingCtrl.text.trim()) ?? 0;

      // Step 1: Update tblRooms
      await widget.roomRef.child(widget.room.key).update({
        'RoomSize': _sizeCtrl.text.trim(),
        'RoomSharing': _sharingCtrl.text.trim(),
      });

      // Step 2: Update tblBeds
      final bedRef = FirebaseDatabase.instance.ref('PG_helper/tblBeds');
      final bedSnapshot = await bedRef.get();

      if (bedSnapshot.exists) {
        final bedsMap = Map<String, dynamic>.from(bedSnapshot.value as Map);

        for (final entry in bedsMap.entries) {
          final roomId = entry.key;
          final roomBeds = Map<String, dynamic>.from(entry.value);

          for (final bedEntry in roomBeds.entries) {
            final bedData = Map<String, dynamic>.from(bedEntry.value);
            if (bedData['roomNumber'] == roomNumber) {
              final currentBedCount = roomBeds.entries
                  .where((e) => e.key.startsWith('bed'))
                  .length;

              if (newSharing > currentBedCount) {
                for (int i = currentBedCount + 1; i <= newSharing; i++) {
                  final newBed = {
                    'roomNumber': roomNumber,
                    'status': 'available',
                  };
                  await bedRef.child('$roomId/bed$i').set(newBed);
                }
              }

              if (newSharing < currentBedCount) {
                for (int i = currentBedCount; i > newSharing; i--) {
                  await bedRef.child('$roomId/bed$i').remove();
                }
              }

              break;
            }
          }
        }
      }

      // Step 3: Update tblUser sharing if user already allocated to the room
      final userRef = FirebaseDatabase.instance.ref('PG_helper/tblUser');
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userMap = Map<String, dynamic>.from(userSnapshot.value as Map);

        for (final entry in userMap.entries) {
          final userKey = entry.key;
          final userData = Map<String, dynamic>.from(entry.value);

          if (userData['RoomNumber'] == roomNumber) {
            await userRef.child(userKey).update({'Sharing': _sharingCtrl.text.trim()});
          }
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Room ${widget.room.roomNumber}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _sizeCtrl,
              decoration: const InputDecoration(labelText: 'Room Size'),
            ),
            TextField(
              controller: _sharingCtrl,
              decoration: const InputDecoration(labelText: 'Room Sharing'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving ? const CircularProgressIndicator() : const Text('Save'),
        ),
      ],
    );
  }
}

class _EditBedDialog extends StatefulWidget {
  final BedRetrievalModel bed;
  final DatabaseReference bedRef;

  const _EditBedDialog({required this.bed, required this.bedRef});

  @override
  State<_EditBedDialog> createState() => _EditBedDialogState();
}

class _EditBedDialogState extends State<_EditBedDialog> {
  late final TextEditingController _statusCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _statusCtrl = TextEditingController(text: widget.bed.status);
  }

  @override
  void dispose() {
    _statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });
    try {
      await widget.bedRef.child(widget.bed.id).update({
        'status': _statusCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Bed ${widget.bed.id}'),
      content: SingleChildScrollView(
        child: TextField(
          controller: _statusCtrl,
          decoration: const InputDecoration(labelText: 'Status'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving ? const CircularProgressIndicator() : const Text('Save'),
        ),
      ],
    );
  }
}
