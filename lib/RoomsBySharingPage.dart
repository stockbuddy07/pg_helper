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

  @override
  void initState() {
    super.initState();
    totalBeds = int.tryParse(widget.sharing) ?? 0;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      final roomFuture = _roomRef.get();
      final bedFuture = _bedRef.get();
      final results = await Future.wait([roomFuture, bedFuture]);

      final roomSnapshot = results[0];
      final bedSnapshot = results[1];

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.sharing}-Sharing Rooms"),
        backgroundColor: const Color(0xD72A8AEA),
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
            childAspectRatio: 4 / 3, // Bigger card
          ),
          itemBuilder: (context, index) {
            final room = _rooms[index];
            final cardColor = _roomCardColors[room.key] ?? Colors.white;
            final availableBeds = _availableBedsCount[room.key] ?? 0;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomDetailPage(roomId: room.key),
                  ),
                );
              },
              child: Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(0.0),
                      physics: const NeverScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Room No: ${room.roomNumber}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
                                children: List.generate(
                                  totalBeds,
                                      (_) => const Icon(Icons.bed, size: 18, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Available Beds: $availableBeds / $totalBeds",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),

      ),
    );
  }
}
