import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/RoomRetrievalModel.dart';
import 'RoomDetailsPage.dart';

class RoomsBySharingPage extends StatefulWidget {
  final String sharing;

  RoomsBySharingPage({required this.sharing});

  @override
  _RoomsBySharingPageState createState() => _RoomsBySharingPageState();
}

class _RoomsBySharingPageState extends State<RoomsBySharingPage> {
  final DatabaseReference _roomRef = FirebaseDatabase.instance.ref('PG_helper/tblRooms');
  final DatabaseReference _bedRef = FirebaseDatabase.instance.ref('PG_helper/tblBeds');

  List<RoomRetrievalModel> _rooms = [];
  Map<String, Color> _roomCardColors = {};
  Map<String, int> _availableBedsCount = {};
  bool _isLoading = true;
  late final int totalBeds;

  Stream<DatabaseEvent>? _roomStream;
  Stream<DatabaseEvent>? _bedStream;

  @override
  void initState() {
    super.initState();
    totalBeds = int.tryParse(widget.sharing) ?? 0;
    _listenToDataChanges();
  }

  void _listenToDataChanges() {
    _roomStream = _roomRef.onValue;
    _bedStream = _bedRef.onValue;

    _roomStream!.listen((_) => _loadAllData());
    _bedStream!.listen((_) => _loadAllData());

    _loadAllData(); // Initial load
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      final roomSnapshot = await _roomRef.get();
      final bedSnapshot = await _bedRef.get();

      final roomData = (roomSnapshot.value as Map?)?.cast<String, dynamic>();
      final bedData = (bedSnapshot.value as Map?)?.cast<String, dynamic>();

      if (roomData == null) {
        setState(() {
          _rooms = [];
          _isLoading = false;
        });
        return;
      }

      final List<RoomRetrievalModel> loadedRooms = [];
      final Map<String, Color> colorMap = {};
      final Map<String, int> availableMap = {};

      for (final entry in roomData.entries) {
        final room = RoomRetrievalModel.fromMap(entry.key, entry.value);
        if (room.roomSharing == widget.sharing) {
          loadedRooms.add(room);

          final beds = (bedData?[entry.key] as Map?)?.cast<String, dynamic>();
          int availableCount = 0;
          int notAvailableCount = 0;

          if (beds != null) {
            for (final bed in beds.values) {
              final bedStatus = (bed as Map)['status'];
              if (bedStatus == 'available') {
                availableCount++;
              } else if (bedStatus == 'not_available') {
                notAvailableCount++;
              }
            }
          }

          colorMap[entry.key] =
          notAvailableCount == totalBeds && totalBeds > 0 ? Colors.red[100]! : Colors.green[100]!;

          availableMap[entry.key] = availableCount;
        }
      }

      loadedRooms.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));

      setState(() {
        _rooms = loadedRooms;
        _roomCardColors = colorMap;
        _availableBedsCount = availableMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCard(BuildContext context, RoomRetrievalModel room, Color cardColor, int availableBeds) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailPage(roomId: room.key),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room, size: 36, color: cardColor),
            const SizedBox(height: 12),
            Text(
              "Room No: ${room.roomNumber}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: List.generate(
                totalBeds,
                    (_) => const Icon(Icons.bed, size: 18, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Available: $availableBeds / $totalBeds",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _roomStream = null;
    _bedStream = null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.sharing}-Sharing Rooms"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
          ? Center(child: Text("No rooms found for ${widget.sharing}-sharing."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: _rooms.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final room = _rooms[index];
            final cardColor = _roomCardColors[room.key] ?? Colors.blueAccent;
            final availableBeds = _availableBedsCount[room.key] ?? 0;

            return _buildCard(context, room, cardColor, availableBeds);
          },
        ),
      ),
    );
  }
}
