// All other imports stay the same
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/RegisterRetrieveModel.dart';

class RoomDetailPage extends StatefulWidget {
  final String roomId;
  RoomDetailPage({required this.roomId});

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final DatabaseReference _roomRef = FirebaseDatabase.instance.ref().child('PG_helper/tblRooms');
  final DatabaseReference _bedRef = FirebaseDatabase.instance.ref().child('PG_helper/tblBeds');
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('PG_helper/tblUser');

  Map<dynamic, dynamic>? roomData;
  bool isLoading = true;

  int sharingCount = 0;
  String roomNumber = '';
  String roomSize = '';
  Map<String, String> bedStatuses = {};
  Color roomColor = Colors.green.shade300;

  @override
  void initState() {
    super.initState();
    _fetchRoomDetails();
  }

  Future<void> _fetchRoomDetails() async {
    final roomSnapshot = await _roomRef.child(widget.roomId).get();

    if (roomSnapshot.exists) {
      roomData = roomSnapshot.value as Map<dynamic, dynamic>;
      sharingCount = int.tryParse(roomData!['RoomSharing'].toString()) ?? 0;
      roomNumber = roomData!['RoomNumber'] ?? '';
      roomSize = roomData!['RoomSize'] ?? '';
    } else {
      roomData = null;
    }

    final bedsSnapshot = await _bedRef.child(widget.roomId).get();
    int notAvailableCount = 0;

    if (bedsSnapshot.exists) {
      final bedsData = bedsSnapshot.value as Map<dynamic, dynamic>;
      for (var entry in bedsData.entries) {
        final bedId = entry.key;
        final bedData = entry.value as Map<dynamic, dynamic>;
        final status = bedData['status'] ?? 'available';
        bedStatuses[bedId] = status;
        if (status == 'not_available') notAvailableCount++;

        if (bedData['roomNumber'] != roomNumber) {
          await _bedRef.child('${widget.roomId}/$bedId').update({'roomNumber': roomNumber});
        }
      }
    } else {
      for (int i = 1; i <= sharingCount; i++) {
        String bedId = 'bed$i';
        bedStatuses[bedId] = 'available';
        await _bedRef.child('${widget.roomId}/$bedId').set({
          'status': 'available',
          'roomNumber': roomNumber,
        });
      }
    }

    roomColor = (notAvailableCount == sharingCount && sharingCount > 0)
        ? Colors.red.shade300
        : Colors.green.shade300;

    setState(() {
      isLoading = false;
    });
  }

  void _onBedTap(String bedId) async {
    final bedStatus = bedStatuses[bedId] ?? 'available';

    if (bedStatus != 'available') {
      final bedSnapshot = await _bedRef.child('${widget.roomId}/$bedId').get();

      if (bedSnapshot.exists) {
        final bedData = bedSnapshot.value as Map<dynamic, dynamic>;
        String fullname = bedData['fullname'] ?? 'Unknown';
        String contact = bedData['contact'] ?? 'Unknown';

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Bed Unavailable'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full Name: $fullname'),
                SizedBox(height: 8),
                Text('Contact: $contact'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _bedRef.child('${widget.roomId}/$bedId').update({
                    'status': 'available',
                    'fullname': null,
                    'contact': null,
                  });

                  final usersSnapshot = await _userRef.get();
                  if (usersSnapshot.exists) {
                    final usersMap = usersSnapshot.value as Map<dynamic, dynamic>;
                    for (var entry in usersMap.entries) {
                      final user = RegisterRetrieveModel.fromJson(entry.value, entry.key);
                      if (user.contact == contact) {
                        await _userRef.child(user.key!).update({
                          'BedStatus': 'unallocated',
                          'RoomNumber': null,
                          'Sharing': null,
                          'BedNumber': null,
                        });
                        break;
                      }
                    }
                  }

                  Navigator.pop(context);
                  setState(() {
                    bedStatuses[bedId] = 'available';
                    _updateRoomColor();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bed deallocated successfully')),
                  );
                },
                child: Text('Deallocate'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bed data not found.')),
        );
      }
      return;
    }

    final phoneNumber = await _showPhoneNumberDialog();
    if (phoneNumber == null) return;

    final usersSnapshot = await _userRef.get();
    RegisterRetrieveModel? matchedUser;

    if (usersSnapshot.exists) {
      final usersMap = usersSnapshot.value as Map<dynamic, dynamic>;
      for (var entry in usersMap.entries) {
        final user = RegisterRetrieveModel.fromJson(entry.value, entry.key);
        if (user.contact == phoneNumber) {
          matchedUser = user;
          break;
        }
      }
    }

    if (matchedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NOT FOUND ANY USER!!')),
      );
      return;
    }

    if (matchedUser.bedStatus == 'allocated') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User already allocated BED.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Allocation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name: ${matchedUser?.name} ${matchedUser?.Lastname}"),
            SizedBox(height: 8),
            Text("Contact: ${matchedUser?.contact}"),
            SizedBox(height: 16),
            Text("Are you sure you want to allocate this bed to the above user?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    String fullName = '${matchedUser.name} ${matchedUser.Lastname}';
    await _bedRef.child('${widget.roomId}/$bedId').update({
      'status': 'not_available',
      'fullname': fullName,
      'contact': matchedUser.contact,
    });

    await _userRef.child(matchedUser.key!).update({
      'BedStatus': 'allocated',
      'RoomNumber': roomNumber,
      'Sharing': sharingCount.toString(),
      'BedNumber': bedId,
    });

    setState(() {
      bedStatuses[bedId] = 'not_available';
      _updateRoomColor();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bed Allocated successfully!')),
    );
  }

  Future<String?> _showPhoneNumberDialog() async {
    String? phone;
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Phone Number to Allocate BED'),
        content: TextField(
          keyboardType: TextInputType.phone,
          onChanged: (val) => phone = val,
          decoration: InputDecoration(hintText: 'Phone Number'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, phone), child: Text('Submit')),
        ],
      ),
    );
  }

  void _updateRoomColor() {
    final notAvailable = bedStatuses.values.where((s) => s == 'not_available').length;
    roomColor = (notAvailable == sharingCount && sharingCount > 0)
        ? Colors.red.shade300
        : Colors.green.shade300;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Room Details'), backgroundColor: roomColor),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (roomData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Room Details'), backgroundColor: roomColor),
        body: Center(child: Text("Room not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Room No: $roomNumber'), backgroundColor: roomColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Room Size: $roomSize", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: sharingCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  String bedId = 'bed${index + 1}';
                  String status = bedStatuses[bedId] ?? 'available';
                  bool isAvailable = status == 'available';

                  return GestureDetector(
                    onTap: () => _onBedTap(bedId),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bed, size: 40, color: isAvailable ? Colors.green : Colors.red),
                            SizedBox(height: 8),
                            Text(
                              "$bedId\n${isAvailable ? "Available" : "Not Available"}",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
