class RoomRetrievalModel {
  final String key;
  final String roomNumber;
  final String roomSize;
  final String roomSharing;  // Added sharing too, since you use it on details page

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
